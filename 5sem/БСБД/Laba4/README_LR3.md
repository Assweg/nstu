## Лабораторная работа №3. Построчная изоляция с RLS

### Ось сегментации
- Ось изоляции (SEG): филиалы/студии дубляжа.
- Новый справочник `ref.segments` содержит 10 сегментов (`SEG-MSK`, `SEG-SPB`, ...), жёстко связанный 1:1 с `ref.studios`.
- Все ключевые таблицы `app.*` получили колонку `segment_id` + индексы `segment_id + ключ фильтрации` для ускорения политик:
  - `app.projects(segment_id, status)`
  - `app.contracts(segment_id, actor_id)`
  - `app.recording_sessions(segment_id, session_date)`
  - `app.audio_archives(segment_id, session_id)`
  - `app.voice_roles(segment_id, project_id)`
  - `app.actors(segment_id, actor_id)`
- Таблица `app.segment_role_acl` хранит соответствия `role_name ↔ segment_id` и используется для валидации контекста.

### Политики RLS
Все таблицы включены в режим `ENABLE ROW LEVEL SECURITY` + `FORCE ROW LEVEL SECURITY`. Политики строятся на выражении  
`current_user = 'auditor' OR app.segment_is_visible(segment_id)`, что сразу добавляет «белый список» для аудитора. Пример (`lr3_02_rls.sql`):

```
CREATE POLICY seg_projects_select ON app.projects
    FOR SELECT
    TO app_reader, app_writer, studio_manager, voice_actor, auditor
    USING (current_user = 'auditor' OR app.segment_is_visible(segment_id));

CREATE POLICY seg_projects_write ON app.projects
    FOR INSERT, UPDATE, DELETE
    TO app_writer, studio_manager
    USING (app.segment_is_visible(segment_id))
    WITH CHECK (app.segment_is_visible(segment_id));
```

Аналогичные политики заданы для `app.actors`, `app.contracts`, `app.recording_sessions`, `app.audio_archives`, `app.voice_roles`.  
`dml_admin` имеет отдельные политики `FOR ALL USING (TRUE)` без ограничений для массовых операций.

### Функция передачи контекста
```
CREATE OR REPLACE FUNCTION app.set_session_ctx(p_segment_id INTEGER, p_actor_id INTEGER DEFAULT NULL)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = app, ref, public
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM app.segment_role_acl
        WHERE role_name = current_user
          AND segment_id = p_segment_id
    ) THEN
        RAISE EXCEPTION 'Роль % не имеет доступа к сегменту %', current_user, p_segment_id;
    END IF;

    PERFORM set_config('app.segment_id', p_segment_id::TEXT, TRUE);

    IF p_actor_id IS NULL THEN
        PERFORM set_config('app.actor_id', NULL, TRUE);
    ELSE
        IF NOT EXISTS (
            SELECT 1 FROM app.actors
            WHERE actor_id = p_actor_id
              AND segment_id = p_segment_id
        ) THEN
            RAISE EXCEPTION 'Актёр % не принадлежит сегменту %', p_actor_id, p_segment_id;
        END IF;
        PERFORM set_config('app.actor_id', p_actor_id::TEXT, TRUE);
    END IF;
END;
$$;
```

- Проверяет, что текущая роль присутствует в `app.segment_role_acl`.
- Для роли `voice_actor` дополнительно проверяется принадлежность актёра сегменту (используется в `app.actor_scope_allows()`).
- Устанавливает безопасные GUC `app.segment_id` и `app.actor_id` через `SET LOCAL` (`set_config(..., true)`).

### Тесты изоляции
`lr3_03_tests.sql` содержит 9 сценариев (требовалось ≥ 8):
1. Чтение чужих строк `app_writer` → пустой набор.
2. INSERT с неверным `segment_id` → ошибка.
3. INSERT в своём сегменте → успех, затем удаление записи.
4. `voice_actor` не может выбрать чужой сегмент в `set_session_ctx`.
5. `set_session_ctx` отклоняет несоответствие `actor_id ↔ segment`.
6. `studio_manager` успешно изменяет данные внутри своего сегмента.
7. Попытка подмены `segment_id` в UPDATE блокируется.
8. `auditor` видит все сегменты без установки контекста.
9. `voice_actor` читает собственные контракты после корректного `set_session_ctx`.

Каждый тест выводит `RAISE NOTICE` о результате и восстанавливает исходные данные (вставки/обновления выполняются внутри блока с откатом/обратной операцией).

### Режим auditor
- В политике каждого объекта присутствует часть `current_user = 'auditor' OR ...`, что позволяет аудитору видеть все строки независимо от GUC.
- `script5.sql` теперь выдаёт роли `auditor` права `USAGE` на схему `app` и `SELECT` на все таблицы `app.*`.
- Тест 8 (`lr3_03_tests.sql`) подтверждает, что `auditor` получает строки из ≥3 сегментов даже без `app.set_session_ctx`.

### Быстрый запуск через Docker
```
./lr3_run_all.sh
```
Скрипт автоматически:
- проверяет наличие `docker compose` / `docker-compose`;
- поднимает стек (если он ещё не запущен);
- ждёт готовности контейнера `dubbing_studio_postgres`;
- выполняет `lr3_01_segment_model.sql`, `lr3_02_rls.sql`, `lr3_03_tests.sql` внутри контейнера.

### Ручное выполнение (если нужно без скрипта)
```
psql -U postgres -d dubbing_studio -f lr3_01_segment_model.sql
psql -U postgres -d dubbing_studio -f lr3_02_rls.sql
psql -U postgres -d dubbing_studio -f lr3_03_tests.sql
```

После выполнения всех скриптов новые сегменты и политики автоматически применяются при полном деплойменте (Docker выполняет их в алфавитном порядке после ЛР1 и ЛР2).


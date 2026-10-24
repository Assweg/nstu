# Настройка pgAdmin

## Быстрый старт

1. Запустите контейнеры:
```bash
./run_docker.sh start
```

2. Откройте pgAdmin в браузере:
```bash
./run_docker.sh pgadmin
```

Или откройте вручную: **http://localhost:5050**

## Учетные данные

**Для входа в pgAdmin:**
- **Email**: `admin@dubbing.studio`
- **Password**: `admin123`

## Подключение к базе данных

После входа в pgAdmin выполните следующие шаги:

### Пошаговая инструкция:

1. **В левой панели найдите раздел "Servers"** (обычно вверху дерева объектов)

2. **Правой кнопкой мыши нажмите на "Servers"** → в меню выберите **"Register"** → **"Server..."**

3. Откроется окно "Register - Server". Заполните следующие вкладки:

   **Вкладка "General":**
   - **Name**: `Dubbing Studio DB`
   - **Server group**: `Servers` (по умолчанию)
   - **Comments**: `База данных студии дубляжа - ЛР1 и ЛР2` (опционально)

   **Вкладка "Connection":**
   - **Host name/address**: `dubbing-studio-db` ⚠️ **ВАЖНО: Используйте имя сервиса из Docker, НЕ localhost!**
   - **Port**: `5432`
   - **Maintenance database**: `dubbing_studio`
   - **Username**: `postgres`
   - **Password**: `secure_password_123`
   - **Save password**: ✅ (отметьте галочку, чтобы не вводить пароль каждый раз)

   **Вкладка "Advanced"** (опционально):
   - **DB restriction**: можно оставить пустым или указать `dubbing_studio`

4. Нажмите кнопку **"Save"** внизу окна

5. Сервер появится в дереве объектов слева под разделом "Servers"

6. Разверните сервер → **"Databases"** → **"dubbing_studio"** → **"Schemas"** для просмотра структуры БД

### ⚠️ Важные моменты:

- **Host name/address** должен быть `dubbing-studio-db` (имя сервиса Docker), а НЕ `localhost`!
- Это важно, потому что pgAdmin работает внутри Docker-сети и подключается к PostgreSQL через внутреннее имя сервиса
- Если использовать `localhost`, подключение не будет работать

## Использование

После подключения вы сможете:
- Просматривать структуру базы данных
- Выполнять SQL-запросы
- Просматривать данные таблиц
- Анализировать журнал вызовов функций (`audit.function_calls`)
- Просматривать логи аудита
- Управлять схемами, таблицами, функциями и другими объектами БД

## Полезные запросы

### Просмотр журнала вызовов функций
```sql
SELECT * FROM audit.function_calls 
ORDER BY call_time DESC 
LIMIT 20;
```

### Статистика по функциям
```sql
SELECT 
    function_name,
    COUNT(*) as total_calls,
    COUNT(*) FILTER (WHERE success = true) as successful,
    COUNT(*) FILTER (WHERE success = false) as failed,
    ROUND(AVG(execution_time_ms)::NUMERIC, 2) as avg_time_ms
FROM audit.function_calls
WHERE function_schema = 'app'
GROUP BY function_name
ORDER BY total_calls DESC;
```

### Просмотр данных контрактов
```sql
SELECT * FROM app.contracts LIMIT 10;
```

## Примечания

- pgAdmin работает в отдельном контейнере и автоматически подключается к PostgreSQL через внутреннюю Docker-сеть
- Данные pgAdmin сохраняются в Docker volume `pgadmin_data`
- При удалении контейнера pgAdmin настройки серверов сохраняются
- Для полного удаления данных pgAdmin используйте: `docker volume rm laba2_pgadmin_data`


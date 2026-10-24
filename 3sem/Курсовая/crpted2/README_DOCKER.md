Запуск в Docker

1. Собрать и запустить:

```bash
docker compose up --build -d
```

2. Проверить приложение:

- Откройте http://localhost:755

3. Остановка:

```bash
docker compose down
```

Заметки:
- Конфигурация БД задаётся в `docker-compose.yml`.
- Схема БД создаётся из `db/init.sql`.
- Сидинг данных выполняет сервис `seeder` (скрипт `import_data.js`).

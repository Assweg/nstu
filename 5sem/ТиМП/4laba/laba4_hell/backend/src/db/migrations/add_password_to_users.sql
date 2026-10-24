-- Добавление колонки password
ALTER TABLE users ADD COLUMN IF NOT EXISTS password VARCHAR(255) NOT NULL DEFAULT '';
 
-- Обновление существующих записей (если есть)
UPDATE users SET password = '$2a$10$your_default_hash' WHERE password = ''; 
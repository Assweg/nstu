-- Добавление колонки updated_at в таблицу users
ALTER TABLE users ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP; 
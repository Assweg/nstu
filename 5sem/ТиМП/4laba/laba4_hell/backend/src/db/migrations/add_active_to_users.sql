-- Добавление колонки active
ALTER TABLE users ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true;

-- Обновление существующих записей
UPDATE users SET active = true WHERE active IS NULL; 
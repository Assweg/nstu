-- Создание таблицы пользователей
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание таблицы энергообъектов
CREATE TABLE energy_objects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    capacity DECIMAL(10, 2),
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    last_inspection TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание таблицы инцидентов
CREATE TABLE incidents (
    id SERIAL PRIMARY KEY,
    object_id INTEGER REFERENCES energy_objects(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    severity VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'open',
    reported_by INTEGER REFERENCES users(id),
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- Создание таблицы отчетов
CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    object_id INTEGER REFERENCES energy_objects(id),
    author_id INTEGER REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    report_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Создание таблицы мониторинга показателей
CREATE TABLE monitoring_data (
    id SERIAL PRIMARY KEY,
    object_id INTEGER REFERENCES energy_objects(id),
    parameter_name VARCHAR(50) NOT NULL,
    parameter_value DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Вставка тестовых данных
INSERT INTO users (username, email, password_hash, role) VALUES
('admin', 'admin@energy.com', '$2b$10$rMN78bXjXQXRYZ5j2kL8q.7eKqv2H8QZ9z.9X9q5Z5j2kL8q.7eKq', 'admin'),
('operator', 'operator@energy.com', '$2b$10$rMN78bXjXQXRYZ5j2kL8q.7eKqv2H8QZ9z.9X9q5Z5j2kL8q.7eKq', 'operator');

INSERT INTO energy_objects (name, location, type, capacity, status) VALUES
('ТЭЦ-5', 'Новосибирск, ул. Станционная, 1', 'Тепловая электростанция', 1200.00, 'active'),
('Новосибирская ГЭС', 'Новосибирск, ул. Новоморская, 4', 'Гидроэлектростанция', 455.00, 'active'); 

-- Дополнительные энергообъекты
INSERT INTO Energy_objects (name, location, type, capacity, status, last_inspection) VALUES
('Солнечная станция "Сибирь"', 'Новосибирская обл., Бердск', 'Солнечная электростанция', 15.50, 'active', '2023-05-15'),
('ВЭС "Алтайские горы"', 'Алтайский край, с. Платово', 'Ветряная электростанция', 60.00, 'active', '2023-06-20'),
('ТЭЦ-3', 'Новосибирск, ул. Тепловая, 12', 'Тепловая электростанция', 850.00, 'maintenance', '2023-04-10'),
('Мини-ГЭС "Быстрая"', 'Новосибирская обл., р. Бердь', 'Гидроэлектростанция', 5.20, 'active', '2023-07-05'),
('Биоэнергостанция "Эко"', 'Новосибирск, промзона', 'Биоэнергетика', 8.75, 'active', '2023-03-28'),
('Подстанция "Центральная"', 'Новосибирск, центр', 'Электроподстанция', NULL, 'active', '2023-08-12'),
('ТЭЦ-2', 'Новосибирск, ул. Энергетиков, 7', 'Тепловая электростанция', 950.00, 'active', '2023-09-01');

-- Инциденты
INSERT INTO Incidents (object_id, title, description, severity, status, reported_by, reported_at, resolved_at) VALUES
(1, 'Утечка теплоносителя', 'Обнаружена утечка в магистральном трубопроводе', 'high', 'resolved', 2, '2023-10-05 08:12:00', '2023-10-06 15:30:00'),
(2, 'Падение уровня воды', 'Уровень водохранилища ниже критической отметки', 'medium', 'open', 2, '2023-10-10 09:45:00', NULL),
(3, 'Плановый ремонт', 'Плановые ремонтные работы турбины №2', 'low', 'resolved', 1, '2023-09-15 07:00:00', '2023-09-20 18:00:00'),
(4, 'Поломка генератора', 'Отказ генератора на ветряке №7', 'high', 'in_progress', 2, '2023-10-12 11:20:00', NULL),
(5, 'Задымление в котельной', 'Обнаружено задымление в помещении котельной', 'critical', 'resolved', 1, '2023-08-22 14:05:00', '2023-08-22 19:40:00'),
(6, 'Повреждение ЛЭП', 'Обрыв провода на линии 110кВ', 'high', 'in_progress', 2, '2023-10-15 06:30:00', NULL),
(7, 'Неисправность датчиков', 'Отказ системы мониторинга параметров', 'medium', 'open', 2, '2023-10-14 16:45:00', NULL),
(1, 'Перегрузка сети', 'Превышение допустимой нагрузки в вечерние часы', 'medium', 'open', 2, '2023-10-16 19:20:00', NULL);

-- Отчеты
INSERT INTO Reports (object_id, author_id, title, content, report_type, created_at, updated_at) VALUES
(1, 1, 'Ежемесячный отчет ТЭЦ-5', 'Полный отчет о работе станции за сентябрь 2023', 'monthly', '2023-10-01 10:00:00', NULL),
(2, 2, 'Анализ эффективности ГЭС', 'Детальный анализ КПД турбин за III квартал', 'quarterly', '2023-10-05 14:30:00', '2023-10-06 09:15:00'),
(3, 1, 'Отчет о ремонтных работах', 'Документация по плановому ремонту оборудования', 'repair', '2023-09-21 11:20:00', NULL),
(4, 2, 'Ввод в эксплуатацию ВЭС', 'Акт ввода новых ветрогенераторов в эксплуатацию', 'commissioning', '2023-07-01 12:00:00', NULL),
(5, 1, 'Годовой отчет ТЭЦ-3', 'Итоги работы за 2022 год и планы на 2023', 'annual', '2023-01-15 15:45:00', NULL),
(6, 2, 'Инспекция подстанции', 'Результаты плановой инспекции оборудования', 'inspection', '2023-08-15 09:30:00', '2023-08-16 10:20:00'),
(7, 1, 'Отчет по безопасности', 'Анализ показателей безопасности за месяц', 'safety', '2023-10-10 13:10:00', NULL),
(8, 2, 'Мониторинг выбросов', 'Отчет по выбросам загрязняющих веществ', 'environment', '2023-09-28 16:25:00', NULL);

-- Данные мониторинга
INSERT INTO Monitoring_data (object_id, parameter_name, parameter_value, unit, timestamp) VALUES
(1, 'Температура', 245.5, '°C', '2023-10-16 08:00:00'),
(1, 'Давление', 18.7, 'МПа', '2023-10-16 08:00:00'),
(2, 'Уровень воды', 12.4, 'м', '2023-10-16 08:05:00'),
(2, 'Выработка', 320.0, 'МВт', '2023-10-16 08:05:00'),
(3, 'Температура', 190.2, '°C', '2023-10-16 08:10:00'),
(3, 'Выработка', 425.5, 'МВт', '2023-10-16 08:10:00'),
(4, 'Скорость ветра', 8.2, 'м/с', '2023-10-16 08:15:00'),
(4, 'Выработка', 28.7, 'МВт', '2023-10-16 08:15:00'),
(5, 'Температура', 210.8, '°C', '2023-10-16 08:20:00'),
(5, 'Давление', 15.3, 'МПа', '2023-10-16 08:20:00'),
(6, 'Напряжение', 109.5, 'кВ', '2023-10-16 08:25:00'),
(6, 'Нагрузка', 78.2, '%', '2023-10-16 08:25:00'),
(7, 'Температура', 230.0, '°C', '2023-10-16 08:30:00'),
(7, 'Выработка', 510.2, 'МВт', '2023-10-16 08:30:00'),
(8, 'Напряжение', 10.2, 'кВ', '2023-10-16 08:35:00'),
(8, 'Ток', 452.7, 'А', '2023-10-16 08:35:00');
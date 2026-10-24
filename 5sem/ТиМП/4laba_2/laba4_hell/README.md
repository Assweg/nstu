# Система мониторинга энергообъектов НСО

Веб-приложение для мониторинга и управления энергетическими объектами в Новосибирской области.

## Функциональность

- Мониторинг состояния энергообъектов в реальном времени
- Управление инцидентами и авариями
- Создание и управление отчетами
- Система аутентификации и авторизации
- Ролевая модель доступа (администратор, оператор)
- Визуализация данных с помощью графиков
- API для интеграции с внешними системами

## Технологии

### Фронтенд
- React
- Material-UI
- React Router
- Chart.js
- Axios

### Бэкенд
- Node.js
- Express
- PostgreSQL
- JWT для аутентификации
- Docker

## Требования

- Node.js 18+
- PostgreSQL 14+
- Docker и Docker Compose

## Установка и запуск

1. Клонировать репозиторий:
```bash
git clone https://github.com/your-username/energy-monitoring.git
cd energy-monitoring
```

2. Создать файл `.env` в корневой директории:
```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
POSTGRES_DB=energy_monitoring
JWT_SECRET=your_jwt_secret
```

3. Запустить приложение с помощью Docker Compose:
```bash
docker-compose up -d
```

Приложение будет доступно по адресу: http://localhost:3000

## Разработка

### Запуск фронтенда в режиме разработки:
```bash
cd frontend
npm install
npm start
```

### Запуск бэкенда в режиме разработки:
```bash
cd backend
npm install
npm run dev
```

## API Документация

### Аутентификация

#### POST /api/auth/register
Регистрация нового пользователя
```json
{
  "username": "string",
  "email": "string",
  "password": "string"
}
```

#### POST /api/auth/login
Вход в систему
```json
{
  "username": "string",
  "password": "string"
}
```

### Энергообъекты

#### GET /api/objects
Получение списка всех объектов

#### POST /api/objects
Создание нового объекта
```json
{
  "name": "string",
  "location": "string",
  "type": "string",
  "capacity": "number"
}
```

### Инциденты

#### GET /api/incidents
Получение списка всех инцидентов

#### POST /api/incidents
Создание нового инцидента
```json
{
  "object_id": "number",
  "title": "string",
  "description": "string",
  "severity": "string"
}
```

### Отчеты

#### GET /api/reports
Получение списка всех отчетов

#### POST /api/reports
Создание нового отчета
```json
{
  "object_id": "number",
  "title": "string",
  "content": "string",
  "report_type": "string"
}
```

## Безопасность

- Все пароли хешируются с использованием bcrypt
- Используются JWT токены для аутентификации
- Реализована ролевая модель доступа
- Защита от XSS и CSRF атак
- Безопасное хранение токенов в httpOnly cookies

## CI/CD

Проект использует GitHub Actions для автоматизации процессов:
- Запуск тестов при каждом push и pull request
- Автоматическая сборка Docker образов
- Автоматический деплой на сервер при merge в main ветку

## Лицензия

MIT 
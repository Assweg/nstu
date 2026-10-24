const express = require('express');
const cors = require('cors');
const { sequelize } = require('./models');
const authRoutes = require('./routes/auth');
const objectsRoutes = require('./routes/objects');
const incidentsRoutes = require('./routes/incidents');
const reportsRoutes = require('./routes/reports');
const dashboardRoutes = require('./routes/dashboard');

const app = express();

// Настройка CORS
const corsOptions = {
  origin: ['http://localhost:3001', 'http://localhost:3000'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  preflightContinue: false,
  optionsSuccessStatus: 204
};

app.use(cors(corsOptions));

// Обработка OPTIONS запросов
app.options('*', cors(corsOptions));

app.use(express.json());

// Корневой маршрут
app.get('/', (req, res) => {
  res.json({ 
    message: 'API Системы мониторинга энергообъектов',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      objects: '/api/objects',
      incidents: '/api/incidents',
      reports: '/api/reports',
      dashboard: '/api/dashboard'
    }
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/objects', objectsRoutes);
app.use('/api/incidents', incidentsRoutes);
app.use('/api/reports', reportsRoutes);
app.use('/api/dashboard', dashboardRoutes);

// Обработка 404
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Маршрут не найден',
    path: req.path
  });
});

// Обработка ошибок
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    status: 'error',
    message: 'Внутренняя ошибка сервера',
    details: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

const PORT = process.env.PORT || 5000;

// Синхронизация с базой данных и запуск сервера
sequelize.sync({ force: true }).then(() => {
  app.listen(PORT, () => {
    console.log(`Сервер запущен на порту ${PORT}`);
  });
}); 
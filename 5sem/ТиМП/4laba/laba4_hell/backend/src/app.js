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
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:3001'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  optionsSuccessStatus: 204
}));

// Обработка OPTIONS запросов
app.options('*', cors());

app.use(express.json());

// Маршруты
app.use('/api/auth', authRoutes);
app.use('/api/objects', objectsRoutes);
app.use('/api/incidents', incidentsRoutes);
app.use('/api/reports', reportsRoutes);
app.use('/api/dashboard', dashboardRoutes);

// Обработка ошибок
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    status: 'error',
    message: 'Внутренняя ошибка сервера'
  });
});

module.exports = app; 
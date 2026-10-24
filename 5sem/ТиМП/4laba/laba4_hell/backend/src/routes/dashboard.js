const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { EnergyObject, Incident, Report } = require('../models');
const { Op } = require('sequelize');

// Получить статистику для дашборда
router.get('/', auth, async (req, res) => {
  try {
    const userId = req.user.id;

    // Получаем общую статистику
    const stats = await getStats(userId);
    
    // Получаем последние инциденты
    const recentIncidents = await getRecentIncidents(userId);
    
    // Получаем последние отчеты
    const recentReports = await getRecentReports(userId);

    res.json({
      stats,
      recentIncidents,
      recentReports
    });
  } catch (error) {
    console.error('Ошибка при получении данных дашборда:', error);
    res.status(500).json({ message: 'Ошибка при получении данных дашборда' });
  }
});

// Вспомогательная функция для получения статистики
async function getStats(userId) {
  const [
    totalObjects,
    activeObjects,
    totalIncidents,
    openIncidents,
    totalReports
  ] = await Promise.all([
    EnergyObject.count({ where: { userId } }),
    EnergyObject.count({ where: { userId, status: 'active' } }),
    Incident.count({
      include: [{
        model: EnergyObject,
        as: 'object',
        where: { userId }
      }]
    }),
    Incident.count({
      where: { status: 'open' },
      include: [{
        model: EnergyObject,
        as: 'object',
        where: { userId }
      }]
    }),
    Report.count({ where: { userId } })
  ]);

  return {
    totalObjects,
    activeObjects,
    totalIncidents,
    openIncidents,
    totalReports
  };
}

// Вспомогательная функция для получения последних инцидентов
async function getRecentIncidents(userId) {
  return await Incident.findAll({
    include: [{
      model: EnergyObject,
      as: 'object',
      where: { userId },
      attributes: ['id', 'name']
    }],
    order: [['created_at', 'DESC']],
    limit: 5
  });
}

// Вспомогательная функция для получения последних отчетов
async function getRecentReports(userId) {
  return await Report.findAll({
    where: { userId },
    include: [{
      model: EnergyObject,
      as: 'object',
      attributes: ['id', 'name']
    }],
    order: [['created_at', 'DESC']],
    limit: 5
  });
}

module.exports = router; 
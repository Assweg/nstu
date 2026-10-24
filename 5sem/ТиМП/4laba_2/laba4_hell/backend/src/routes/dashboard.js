const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { Object, Incident, Report, User } = require('../models');
const { Op } = require('sequelize');

// Корневой маршрут дашборда
router.get('/', auth, async (req, res) => {
  try {
    const [stats, recentIncidents, recentReports] = await Promise.all([
      getStats(req.user.id),
      getRecentIncidents(req.user.id),
      getRecentReports(req.user.id)
    ]);

    res.json({
      status: 'success',
      data: {
        stats,
        recentIncidents,
        recentReports
      }
    });
  } catch (error) {
    console.error('Ошибка при получении данных дашборда:', error);
    res.status(500).json({ 
      status: 'error',
      message: 'Ошибка при получении данных дашборда',
      details: error.message
    });
  }
});

// Получить статистику для дашборда
router.get('/stats', auth, async (req, res) => {
  try {
    const stats = await getStats(req.user.id);
    res.json({
      status: 'success',
      data: stats
    });
  } catch (error) {
    console.error('Ошибка при получении статистики:', error);
    res.status(500).json({ 
      status: 'error',
      message: 'Ошибка при получении статистики',
      details: error.message
    });
  }
});

// Получить последние инциденты
router.get('/recent-incidents', auth, async (req, res) => {
  try {
    const incidents = await getRecentIncidents(req.user.id);
    res.json({
      status: 'success',
      data: incidents
    });
  } catch (error) {
    console.error('Ошибка при получении последних инцидентов:', error);
    res.status(500).json({ 
      status: 'error',
      message: 'Ошибка при получении последних инцидентов',
      details: error.message
    });
  }
});

// Получить последние отчеты
router.get('/recent-reports', auth, async (req, res) => {
  try {
    const reports = await getRecentReports(req.user.id);
    res.json({
      status: 'success',
      data: reports
    });
  } catch (error) {
    console.error('Ошибка при получении последних отчетов:', error);
    res.status(500).json({ 
      status: 'error',
      message: 'Ошибка при получении последних отчетов',
      details: error.message
    });
  }
});

// Вспомогательные функции
async function getStats(userId) {
  const [objects, incidents, reports] = await Promise.all([
    Object.count({
      where: { userId }
    }),
    Incident.count({
      where: {
        status: {
          [Op.not]: 'closed'
        }
      },
      include: [{
        model: Object,
        as: 'object',
        where: { userId },
        required: true
      }]
    }),
    Report.count({
      where: {
        userId,
        generatedAt: {
          [Op.gte]: new Date(new Date() - 24 * 60 * 60 * 1000)
        }
      }
    })
  ]);

  const objectsByStatus = await Object.count({
    where: { userId },
    group: 'status'
  });

  const incidentsBySeverity = await Incident.count({
    where: {
      status: {
        [Op.not]: 'closed'
      }
    },
    include: [{
      model: Object,
      as: 'object',
      where: { userId },
      required: true
    }],
    group: 'severity'
  });

  return {
    totalObjects: objects,
    activeIncidents: incidents,
    recentReports: reports,
    objectsByStatus,
    incidentsBySeverity
  };
}

async function getRecentIncidents(userId) {
  return await Incident.findAll({
    where: {
      status: {
        [Op.not]: 'closed'
      }
    },
    include: [{
      model: Object,
      as: 'object',
      where: { userId },
      required: true,
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'username']
      }]
    }],
    order: [['reportedAt', 'DESC']],
    limit: 5
  });
}

async function getRecentReports(userId) {
  return await Report.findAll({
    where: { userId },
    include: [
      {
        model: Object,
        as: 'object',
        include: [{
          model: User,
          as: 'user',
          attributes: ['id', 'username']
        }]
      },
      {
        model: User,
        as: 'user',
        attributes: ['id', 'username']
      }
    ],
    order: [['generatedAt', 'DESC']],
    limit: 5
  });
}

module.exports = router; 
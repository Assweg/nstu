const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');

// Получение данных для графика
router.get('/chart-data', authMiddleware, async (req, res) => {
  try {
    const db = req.app.locals.db;
    const result = await db.query(`
      SELECT 
        date_trunc('hour', timestamp) as hour,
        AVG(parameter_value) as avg_value
      FROM monitoring_data
      WHERE parameter_name = 'power_consumption'
      AND timestamp >= NOW() - INTERVAL '24 hours'
      GROUP BY hour
      ORDER BY hour ASC
    `);

    const labels = result.rows.map(row => 
      new Date(row.hour).toLocaleTimeString('ru-RU', {
        hour: '2-digit',
        minute: '2-digit'
      })
    );
    const values = result.rows.map(row => parseFloat(row.avg_value));

    res.json({
      status: 'success',
      data: {
        labels,
        values
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при получении данных для графика'
    });
  }
});

// Получение последних показателей для объекта
router.get('/object/:id', authMiddleware, async (req, res) => {
  try {
    const db = req.app.locals.db;
    const result = await db.query(`
      SELECT 
        parameter_name,
        parameter_value,
        unit,
        timestamp
      FROM monitoring_data
      WHERE object_id = $1
      AND timestamp >= NOW() - INTERVAL '1 hour'
      ORDER BY timestamp DESC
      LIMIT 10
    `, [req.params.id]);

    res.json({
      status: 'success',
      data: result.rows
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при получении показателей'
    });
  }
});

// Добавление нового показателя
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { object_id, parameter_name, parameter_value, unit } = req.body;
    const db = req.app.locals.db;

    const result = await db.query(`
      INSERT INTO monitoring_data (object_id, parameter_name, parameter_value, unit)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `, [object_id, parameter_name, parameter_value, unit]);

    res.status(201).json({
      status: 'success',
      data: result.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при добавлении показателя'
    });
  }
});

module.exports = router; 
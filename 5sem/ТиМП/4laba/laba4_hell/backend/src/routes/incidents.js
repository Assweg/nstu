const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { Incident, EnergyObject } = require('../models');

// Получить список инцидентов
router.get('/', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const { count, rows } = await Incident.findAndCountAll({
      include: [{
        model: EnergyObject,
        as: 'object',
        where: { userId: req.user.id },
        attributes: ['id', 'name']
      }],
      order: [['created_at', 'DESC']],
      limit,
      offset
    });

    res.json({
      total: count,
      page,
      totalPages: Math.ceil(count / limit),
      incidents: rows
    });
  } catch (error) {
    console.error('Ошибка при получении инцидентов:', error);
    res.status(500).json({ message: 'Ошибка при получении инцидентов' });
  }
});

// Получить инцидент по ID
router.get('/:id', auth, async (req, res) => {
  try {
    const incident = await Incident.findOne({
      where: { id: req.params.id },
      include: [{
        model: EnergyObject,
        as: 'object',
        where: { userId: req.user.id },
        attributes: ['id', 'name']
      }]
    });

    if (!incident) {
      return res.status(404).json({ message: 'Инцидент не найден' });
    }

    res.json(incident);
  } catch (error) {
    console.error('Ошибка при получении инцидента:', error);
    res.status(500).json({ message: 'Ошибка при получении инцидента' });
  }
});

// Создать новый инцидент
router.post('/', auth, async (req, res) => {
  try {
    // Проверяем, принадлежит ли объект пользователю
    const object = await EnergyObject.findOne({
      where: { 
        id: req.body.objectId,
        userId: req.user.id
      }
    });

    if (!object) {
      return res.status(404).json({ message: 'Объект не найден' });
    }

    const incident = await Incident.create(req.body);
    res.status(201).json(incident);
  } catch (error) {
    console.error('Ошибка при создании инцидента:', error);
    res.status(500).json({ message: 'Ошибка при создании инцидента' });
  }
});

// Обновить инцидент
router.put('/:id', auth, async (req, res) => {
  try {
    const incident = await Incident.findOne({
      where: { id: req.params.id },
      include: [{
        model: EnergyObject,
        as: 'object',
        where: { userId: req.user.id }
      }]
    });

    if (!incident) {
      return res.status(404).json({ message: 'Инцидент не найден' });
    }

    await incident.update(req.body);
    res.json(incident);
  } catch (error) {
    console.error('Ошибка при обновлении инцидента:', error);
    res.status(500).json({ message: 'Ошибка при обновлении инцидента' });
  }
});

// Удалить инцидент
router.delete('/:id', auth, async (req, res) => {
  try {
    const incident = await Incident.findOne({
      where: { id: req.params.id },
      include: [{
        model: EnergyObject,
        as: 'object',
        where: { userId: req.user.id }
      }]
    });

    if (!incident) {
      return res.status(404).json({ message: 'Инцидент не найден' });
    }

    await incident.destroy();
    res.json({ message: 'Инцидент успешно удален' });
  } catch (error) {
    console.error('Ошибка при удалении инцидента:', error);
    res.status(500).json({ message: 'Ошибка при удалении инцидента' });
  }
});

module.exports = router; 
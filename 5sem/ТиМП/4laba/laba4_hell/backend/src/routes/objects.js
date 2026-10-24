const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { EnergyObject, User } = require('../models');

// Получить список объектов с пагинацией и фильтрацией
router.get('/', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    
    // Параметры фильтрации
    const filter = {};
    if (req.query.type) filter.type = req.query.type;
    if (req.query.status) filter.status = req.query.status;
    
    // Добавляем фильтр по userId
    filter.userId = req.user.id;

    const { count, rows } = await EnergyObject.findAndCountAll({
      where: filter,
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'username']
      }],
      order: [['created_at', 'DESC']],
      limit,
      offset
    });

    res.json({
      total: count,
      page,
      totalPages: Math.ceil(count / limit),
      objects: rows
    });
  } catch (error) {
    console.error('Ошибка при получении списка объектов:', error);
    res.status(500).json({ message: 'Ошибка при получении списка объектов' });
  }
});

// Получить объект по ID
router.get('/:id', auth, async (req, res) => {
  try {
    const object = await EnergyObject.findOne({
      where: { 
        id: req.params.id,
        userId: req.user.id
      },
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'username']
      }]
    });

    if (!object) {
      return res.status(404).json({ message: 'Объект не найден' });
    }

    res.json(object);
  } catch (error) {
    console.error('Ошибка при получении объекта:', error);
    res.status(500).json({ message: 'Ошибка при получении объекта' });
  }
});

// Создать новый объект
router.post('/', auth, async (req, res) => {
  try {
    const object = await EnergyObject.create({
      ...req.body,
      userId: req.user.id
    });

    res.status(201).json(object);
  } catch (error) {
    console.error('Ошибка при создании объекта:', error);
    res.status(500).json({ message: 'Ошибка при создании объекта' });
  }
});

// Обновить объект
router.put('/:id', auth, async (req, res) => {
  try {
    const object = await EnergyObject.findOne({
      where: { 
        id: req.params.id,
        userId: req.user.id
      }
    });

    if (!object) {
      return res.status(404).json({ message: 'Объект не найден' });
    }

    await object.update(req.body);
    res.json(object);
  } catch (error) {
    console.error('Ошибка при обновлении объекта:', error);
    res.status(500).json({ message: 'Ошибка при обновлении объекта' });
  }
});

// Удалить объект
router.delete('/:id', auth, async (req, res) => {
  try {
    const object = await EnergyObject.findOne({
      where: { 
        id: req.params.id,
        userId: req.user.id
      }
    });

    if (!object) {
      return res.status(404).json({ message: 'Объект не найден' });
    }

    await object.destroy();
    res.json({ message: 'Объект успешно удален' });
  } catch (error) {
    console.error('Ошибка при удалении объекта:', error);
    res.status(500).json({ message: 'Ошибка при удалении объекта' });
  }
});

module.exports = router; 
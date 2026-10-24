const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { Incident, Object, User } = require('../models');

// Получить все инциденты
router.get('/', auth, async (req, res) => {
  try {
    const incidents = await Incident.findAll({
      include: [
        {
          model: Object,
          as: 'object',
          include: [
            {
              model: User,
              as: 'user',
              attributes: ['id', 'username']
            }
          ]
        }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json({
      status: 'success',
      data: incidents
    });
  } catch (error) {
    console.error('Ошибка при получении инцидентов:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при получении инцидентов',
      details: error.message
    });
  }
});

// Получить один инцидент
router.get('/:id', auth, async (req, res) => {
  try {
    const incident = await Incident.findOne({
      where: { id: req.params.id },
      include: [
        {
          model: Object,
          as: 'object',
          include: [
            {
              model: User,
              as: 'user',
              attributes: ['id', 'username']
            }
          ]
        }
      ]
    });

    if (!incident) {
      return res.status(404).json({
        status: 'error',
        message: 'Инцидент не найден',
        details: 'Запрошенный инцидент не существует'
      });
    }

    res.json({
      status: 'success',
      data: incident
    });
  } catch (error) {
    console.error('Ошибка при получении инцидента:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при получении инцидента',
      details: error.message
    });
  }
});

// Создать инцидент
router.post('/', auth, async (req, res) => {
  try {
    // Проверяем и преобразуем objectId в число
    const objectId = parseInt(req.body.objectId);
    if (isNaN(objectId)) {
      return res.status(400).json({
        status: 'error',
        message: 'Ошибка валидации',
        details: 'ID объекта должен быть числом'
      });
    }

    // Проверяем существование объекта
    const object = await Object.findOne({
      where: {
        id: objectId,
        userId: req.user.id
      }
    });

    if (!object) {
      return res.status(404).json({
        status: 'error',
        message: 'Объект не найден',
        details: 'Указанный объект не существует или у вас нет прав доступа к нему'
      });
    }

    const incident = await Incident.create({
      ...req.body,
      objectId,
      reportedAt: new Date()
    });

    const incidentWithRelations = await Incident.findOne({
      where: { id: incident.id },
      include: [
        {
          model: Object,
          as: 'object',
          include: [
            {
              model: User,
              as: 'user',
              attributes: ['id', 'username']
            }
          ]
        }
      ]
    });

    res.status(201).json({
      status: 'success',
      message: 'Инцидент успешно создан',
      data: incidentWithRelations
    });
  } catch (error) {
    console.error('Ошибка при создании инцидента:', error);
    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({
        status: 'error',
        message: 'Ошибка валидации',
        details: error.errors.map(e => e.message)
      });
    }
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при создании инцидента',
      details: error.message
    });
  }
});

// Обновить инцидент
router.put('/:id', auth, async (req, res) => {
  try {
    const incident = await Incident.findByPk(req.params.id);

    if (!incident) {
      return res.status(404).json({
        status: 'error',
        message: 'Инцидент не найден',
        details: 'Запрошенный инцидент не существует'
      });
    }

    await incident.update(req.body);

    const updatedIncident = await Incident.findOne({
      where: { id: incident.id },
      include: [
        {
          model: Object,
          as: 'object',
          include: [
            {
              model: User,
              as: 'user',
              attributes: ['id', 'username']
            }
          ]
        }
      ]
    });

    res.json({
      status: 'success',
      message: 'Инцидент успешно обновлен',
      data: updatedIncident
    });
  } catch (error) {
    console.error('Ошибка при обновлении инцидента:', error);
    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({
        status: 'error',
        message: 'Ошибка валидации',
        details: error.errors.map(e => e.message)
      });
    }
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при обновлении инцидента',
      details: error.message
    });
  }
});

// Удалить инцидент
router.delete('/:id', auth, async (req, res) => {
  try {
    const incident = await Incident.findByPk(req.params.id);

    if (!incident) {
      return res.status(404).json({
        status: 'error',
        message: 'Инцидент не найден',
        details: 'Запрошенный инцидент не существует'
      });
    }

    await incident.destroy();

    res.json({
      status: 'success',
      message: 'Инцидент успешно удален'
    });
  } catch (error) {
    console.error('Ошибка при удалении инцидента:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при удалении инцидента',
      details: error.message
    });
  }
});

module.exports = router; 
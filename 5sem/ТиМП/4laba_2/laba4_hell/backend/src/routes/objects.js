const express = require('express');
const router = express.Router();
const { auth, roleCheck, isOwner } = require('../middleware/auth');
const { Object, User, Incident, Report } = require('../models');

// Получить все объекты
router.get('/', auth, async (req, res) => {
  try {
    const objects = await Object.findAll({
      where: {
        userId: req.user.id
      },
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username']
        },
        {
          model: Incident,
          as: 'incidents',
          separate: true,
          limit: 5,
          order: [['createdAt', 'DESC']]
        },
        {
          model: Report,
          as: 'reports',
          separate: true,
          limit: 5,
          order: [['generatedAt', 'DESC']]
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    res.json({
      status: 'success',
      data: objects
    });
  } catch (error) {
    console.error('Ошибка при получении объектов:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при получении объектов',
      details: error.message
    });
  }
});

// Получить один объект
router.get('/:id', auth, async (req, res) => {
  try {
    const object = await Object.findOne({
      where: {
        id: req.params.id,
        userId: req.user.id
      },
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username']
        },
        {
          model: Incident,
          as: 'incidents',
          separate: true,
          limit: 10,
          order: [['createdAt', 'DESC']]
        },
        {
          model: Report,
          as: 'reports',
          separate: true,
          limit: 10,
          order: [['generatedAt', 'DESC']]
        }
      ]
    });

    if (!object) {
      return res.status(404).json({
        status: 'error',
        message: 'Объект не найден',
        details: 'Запрошенный объект не существует или у вас нет прав доступа к нему'
      });
    }

    res.json({
      status: 'success',
      data: object
    });
  } catch (error) {
    console.error('Ошибка при получении объекта:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при получении объекта',
      details: error.message
    });
  }
});

// Создать объект
router.post('/', auth, async (req, res) => {
  try {
    const object = await Object.create({
      ...req.body,
      userId: req.user.id
    });

    const objectWithRelations = await Object.findOne({
      where: { id: object.id },
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username']
        }
      ]
    });

    res.status(201).json({
      status: 'success',
      message: 'Объект успешно создан',
      data: objectWithRelations
    });
  } catch (error) {
    console.error('Ошибка при создании объекта:', error);
    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({
        status: 'error',
        message: 'Ошибка валидации',
        details: error.errors.map(e => e.message)
      });
    }
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при создании объекта',
      details: error.message
    });
  }
});

// Обновить объект
router.put('/:id', auth, async (req, res) => {
  try {
    const object = await Object.findOne({
      where: {
        id: req.params.id,
        userId: req.user.id
      }
    });

    if (!object) {
      return res.status(404).json({
        status: 'error',
        message: 'Объект не найден',
        details: 'Запрошенный объект не существует или у вас нет прав доступа к нему'
      });
    }

    await object.update(req.body);

    const updatedObject = await Object.findOne({
      where: { id: object.id },
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username']
        }
      ]
    });

    res.json({
      status: 'success',
      message: 'Объект успешно обновлен',
      data: updatedObject
    });
  } catch (error) {
    console.error('Ошибка при обновлении объекта:', error);
    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({
        status: 'error',
        message: 'Ошибка валидации',
        details: error.errors.map(e => e.message)
      });
    }
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при обновлении объекта',
      details: error.message
    });
  }
});

// Удалить объект
router.delete('/:id', auth, async (req, res) => {
  try {
    const object = await Object.findOne({
      where: {
        id: req.params.id,
        userId: req.user.id
      }
    });

    if (!object) {
      return res.status(404).json({
        status: 'error',
        message: 'Объект не найден',
        details: 'Запрошенный объект не существует или у вас нет прав доступа к нему'
      });
    }

    await object.destroy();

    res.json({
      status: 'success',
      message: 'Объект успешно удален'
    });
  } catch (error) {
    console.error('Ошибка при удалении объекта:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при удалении объекта',
      details: error.message
    });
  }
});

module.exports = router; 
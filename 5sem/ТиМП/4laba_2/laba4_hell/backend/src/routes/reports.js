const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { Report, Object, User } = require('../models');
const path = require('path');
const fs = require('fs');
const PDFDocument = require('pdfkit');

// Получить все отчеты
router.get('/', auth, async (req, res) => {
  try {
    const reports = await Report.findAll({
      where: {
        userId: req.user.id
      },
      include: [
        {
          model: Object,
          as: 'object',
          attributes: ['id', 'name', 'type', 'location', 'status']
        },
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username']
        }
      ],
      order: [['generatedAt', 'DESC']]
    });

    res.json({
      status: 'success',
      data: reports
    });
  } catch (error) {
    console.error('Ошибка при получении отчетов:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при получении отчетов',
      details: error.message
    });
  }
});

// Получить один отчет
router.get('/:id', auth, async (req, res) => {
  try {
    const report = await Report.findOne({
      where: {
        id: req.params.id,
        userId: req.user.id
      },
      include: [
        {
          model: Object,
          as: 'object',
          attributes: ['id', 'name', 'type', 'location', 'status']
        },
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username']
        }
      ]
    });

    if (!report) {
      return res.status(404).json({
        status: 'error',
        message: 'Отчет не найден',
        details: 'Запрошенный отчет не существует или у вас нет прав доступа к нему'
      });
    }

    res.json({
      status: 'success',
      data: report
    });
  } catch (error) {
    console.error('Ошибка при получении отчета:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при получении отчета',
      details: error.message
    });
  }
});

// Создать отчет
router.post('/', auth, async (req, res) => {
  try {
    // Проверяем, существует ли объект и принадлежит ли он пользователю
    if (req.body.objectId) {
      const object = await Object.findOne({
        where: {
          id: req.body.objectId,
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
    }

    const report = await Report.create({
      ...req.body,
      userId: req.user.id,
      generatedAt: new Date()
    });

    const reportWithRelations = await Report.findOne({
      where: { id: report.id },
      include: [
        {
          model: Object,
          as: 'object',
          attributes: ['id', 'name', 'type', 'location', 'status']
        },
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username']
        }
      ]
    });

    res.status(201).json({
      status: 'success',
      message: 'Отчет успешно создан',
      data: reportWithRelations
    });
  } catch (error) {
    console.error('Ошибка при создании отчета:', error);
    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({
        status: 'error',
        message: 'Ошибка валидации',
        details: error.errors.map(e => e.message)
      });
    }
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при создании отчета',
      details: error.message
    });
  }
});

// Обновить отчет
router.put('/:id', auth, async (req, res) => {
  try {
    const report = await Report.findOne({
      where: {
        id: req.params.id,
        userId: req.user.id
      }
    });

    if (!report) {
      return res.status(404).json({
        status: 'error',
        message: 'Отчет не найден',
        details: 'Запрошенный отчет не существует или у вас нет прав доступа к нему'
      });
    }

    // Проверяем, существует ли объект и принадлежит ли он пользователю
    if (req.body.objectId) {
      const object = await Object.findOne({
        where: {
          id: req.body.objectId,
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
    }

    await report.update(req.body);

    const updatedReport = await Report.findOne({
      where: { id: report.id },
      include: [
        {
          model: Object,
          as: 'object',
          attributes: ['id', 'name', 'type', 'location', 'status']
        },
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username']
        }
      ]
    });

    res.json({
      status: 'success',
      message: 'Отчет успешно обновлен',
      data: updatedReport
    });
  } catch (error) {
    console.error('Ошибка при обновлении отчета:', error);
    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({
        status: 'error',
        message: 'Ошибка валидации',
        details: error.errors.map(e => e.message)
      });
    }
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при обновлении отчета',
      details: error.message
    });
  }
});

// Удалить отчет
router.delete('/:id', auth, async (req, res) => {
  try {
    const report = await Report.findOne({
      where: {
        id: req.params.id,
        userId: req.user.id
      }
    });

    if (!report) {
      return res.status(404).json({
        status: 'error',
        message: 'Отчет не найден',
        details: 'Запрошенный отчет не существует или у вас нет прав доступа к нему'
      });
    }

    await report.destroy();

    res.json({
      status: 'success',
      message: 'Отчет успешно удален'
    });
  } catch (error) {
    console.error('Ошибка при удалении отчета:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при удалении отчета',
      details: error.message
    });
  }
});

// Скачать отчет
router.get('/:id/download', auth, async (req, res) => {
  try {
    const report = await Report.findOne({
      where: {
        id: req.params.id,
        userId: req.user.id
      },
      include: [
        {
          model: Object,
          as: 'object',
          attributes: ['id', 'name', 'type', 'location', 'status']
        },
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username']
        }
      ]
    });

    if (!report) {
      return res.status(404).json({
        status: 'error',
        message: 'Отчет не найден',
        details: 'Запрошенный отчет не существует или у вас нет прав доступа к нему'
      });
    }

    // Создаем временную директорию, если она не существует
    const tempDir = path.join(__dirname, '../temp');
    if (!fs.existsSync(tempDir)) {
      fs.mkdirSync(tempDir, { recursive: true });
    }

    const tempFilePath = path.join(tempDir, `report_${report.id}.pdf`);

    // Генерируем PDF
    const doc = new PDFDocument();
    const stream = fs.createWriteStream(tempFilePath);

    doc.pipe(stream);

    // Добавляем содержимое в PDF
    doc.fontSize(20)
       .text('Отчет об энергообъекте', { align: 'center' })
       .moveDown();

    doc.fontSize(14)
       .text(`Название отчета: ${report.title}`)
       .moveDown()
       .text(`Тип отчета: ${report.type}`)
       .moveDown()
       .text(`Дата создания: ${new Date(report.generatedAt).toLocaleString('ru-RU')}`)
       .moveDown()
       .text(`Статус: ${report.status}`)
       .moveDown();

    if (report.object) {
      doc.fontSize(16)
         .text('Информация об объекте', { underline: true })
         .moveDown()
         .fontSize(14)
         .text(`Название: ${report.object.name}`)
         .moveDown()
         .text(`Тип: ${report.object.type}`)
         .moveDown()
         .text(`Местоположение: ${report.object.location}`)
         .moveDown()
         .text(`Статус: ${report.object.status}`)
         .moveDown();
    }

    doc.fontSize(16)
       .text('Содержание отчета', { underline: true })
       .moveDown()
       .fontSize(12)
       .text(report.content)
       .moveDown();

    doc.end();

    // Ждем завершения записи файла
    stream.on('finish', () => {
      res.download(tempFilePath, `report_${report.id}.pdf`, (err) => {
        // Удаляем временный файл после отправки
        if (fs.existsSync(tempFilePath)) {
          fs.unlinkSync(tempFilePath);
        }

        if (err) {
          console.error('Ошибка при скачивании отчета:', err);
          if (!res.headersSent) {
            res.status(500).json({
              status: 'error',
              message: 'Ошибка при скачивании отчета',
              details: err.message
            });
          }
        }
      });
    });
  } catch (error) {
    console.error('Ошибка при скачивании отчета:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при скачивании отчета',
      details: error.message
    });
  }
});

module.exports = router; 
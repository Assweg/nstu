const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { Report, User, EnergyObject } = require('../models');
const path = require('path');
const fs = require('fs');
const PDFDocument = require('pdfkit');

// Получить список отчетов
router.get('/', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const filter = { userId: req.user.id };
    if (req.query.type) filter.type = req.query.type;
    if (req.query.status) filter.status = req.query.status;

    const { count, rows } = await Report.findAndCountAll({
      where: filter,
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username']
        },
        {
          model: EnergyObject,
          as: 'object',
          attributes: ['id', 'name']
        }
      ],
      order: [['created_at', 'DESC']],
      limit,
      offset
    });

    res.json({
      total: count,
      page,
      totalPages: Math.ceil(count / limit),
      reports: rows
    });
  } catch (error) {
    console.error('Ошибка при получении отчетов:', error);
    res.status(500).json({ message: 'Ошибка при получении отчетов' });
  }
});

// Получить отчет по ID
router.get('/:id', auth, async (req, res) => {
  try {
    const report = await Report.findOne({
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
          model: EnergyObject,
          as: 'object',
          attributes: ['id', 'name']
        }
      ]
    });

    if (!report) {
      return res.status(404).json({ message: 'Отчет не найден' });
    }

    res.json(report);
  } catch (error) {
    console.error('Ошибка при получении отчета:', error);
    res.status(500).json({ message: 'Ошибка при получении отчета' });
  }
});

// Создать новый отчет
router.post('/', auth, async (req, res) => {
  try {
    if (req.body.objectId) {
      const object = await EnergyObject.findOne({
        where: { 
          id: req.body.objectId,
          userId: req.user.id
        }
      });

      if (!object) {
        return res.status(404).json({ message: 'Объект не найден' });
      }
    }

    const report = await Report.create({
      ...req.body,
      userId: req.user.id
    });

    res.status(201).json(report);
  } catch (error) {
    console.error('Ошибка при создании отчета:', error);
    res.status(500).json({ message: 'Ошибка при создании отчета' });
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
      return res.status(404).json({ message: 'Отчет не найден' });
    }

    if (req.body.objectId) {
      const object = await EnergyObject.findOne({
        where: { 
          id: req.body.objectId,
          userId: req.user.id
        }
      });

      if (!object) {
        return res.status(404).json({ message: 'Объект не найден' });
      }
    }

    await report.update(req.body);
    res.json(report);
  } catch (error) {
    console.error('Ошибка при обновлении отчета:', error);
    res.status(500).json({ message: 'Ошибка при обновлении отчета' });
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
      return res.status(404).json({ message: 'Отчет не найден' });
    }

    await report.destroy();
    res.json({ message: 'Отчет успешно удален' });
  } catch (error) {
    console.error('Ошибка при удалении отчета:', error);
    res.status(500).json({ message: 'Ошибка при удалении отчета' });
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
          model: EnergyObject,
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
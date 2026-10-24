const express = require('express');
const jwt = require('jsonwebtoken');
const { User } = require('../models');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Регистрация
router.post('/register', async (req, res) => {
  try {
    const { username, password } = req.body;

    // Проверка существования пользователя
    const existingUser = await User.findOne({ 
      where: { username },
      attributes: ['id', 'username', 'password', 'role', 'active', 'createdAt', 'updatedAt']
    });
    if (existingUser) {
      return res.status(400).json({
        status: 'error',
        message: 'Пользователь уже существует',
        details: 'Пользователь с таким именем уже зарегистрирован'
      });
    }

    // Создание нового пользователя
    const user = await User.create({ 
      username, 
      password,
      active: true
    });

    // Создание токена
    const token = jwt.sign(
      { id: user.id, username: user.username },
      process.env.JWT_SECRET || 'your_jwt_secret_key',
      { expiresIn: '24h' }
    );

    res.status(201).json({
      status: 'success',
      message: 'Регистрация успешна',
      token
    });
  } catch (error) {
    console.error('Ошибка при регистрации:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при регистрации пользователя',
      details: error.message
    });
  }
});

// Вход
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    // Поиск пользователя
    const user = await User.findOne({ 
      where: { 
        username,
        active: true
      },
      attributes: ['id', 'username', 'password', 'role', 'active', 'createdAt', 'updatedAt']
    });
    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Неверное имя пользователя или пароль',
        details: 'Проверьте правильность введенных данных'
      });
    }

    // Проверка активности пользователя
    if (!user.active) {
      return res.status(401).json({
        status: 'error',
        message: 'Аккаунт деактивирован',
        details: 'Ваш аккаунт был деактивирован. Обратитесь к администратору.'
      });
    }

    // Проверка пароля
    const isValidPassword = await user.comparePassword(password);
    if (!isValidPassword) {
      return res.status(401).json({
        status: 'error',
        message: 'Неверное имя пользователя или пароль',
        details: 'Проверьте правильность введенных данных'
      });
    }

    // Создание токена
    const token = jwt.sign(
      { id: user.id, username: user.username },
      process.env.JWT_SECRET || 'your_jwt_secret_key',
      { expiresIn: '24h' }
    );

    res.json({
      status: 'success',
      message: 'Вход выполнен успешно',
      token
    });
  } catch (error) {
    console.error('Ошибка при входе:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при входе в систему',
      details: error.message
    });
  }
});

// Получить профиль пользователя
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findOne({
      where: {
        id: req.user.id,
        active: true
      },
      attributes: { exclude: ['password'] }
    });
    
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'Пользователь не найден',
        details: 'Пользователь был удален или деактивирован'
      });
    }

    res.json({
      status: 'success',
      data: user
    });
  } catch (error) {
    console.error('Ошибка при получении профиля:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при получении профиля',
      details: error.message
    });
  }
});

// Обновить профиль пользователя
router.put('/profile', auth, async (req, res) => {
  try {
    const { username, email } = req.body;
    const user = await User.findOne({
      where: {
        id: req.user.id,
        active: true
      }
    });

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'Пользователь не найден',
        details: 'Пользователь был удален или деактивирован'
      });
    }

    // Проверяем, не занято ли имя пользователя
    if (username && username !== user.username) {
      const existingUser = await User.findOne({ 
        where: { 
          username,
          active: true
        } 
      });
      if (existingUser) {
        return res.status(400).json({
          status: 'error',
          message: 'Имя пользователя уже занято',
          details: 'Выберите другое имя пользователя'
        });
      }
    }

    await user.update({ username, email });

    res.json({
      status: 'success',
      message: 'Профиль успешно обновлен',
      data: {
        username: user.username,
        email: user.email,
        active: user.active
      }
    });
  } catch (error) {
    console.error('Ошибка при обновлении профиля:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при обновлении профиля',
      details: error.message
    });
  }
});

// Изменить пароль
router.put('/change-password', auth, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const user = await User.findOne({
      where: {
        id: req.user.id,
        active: true
      }
    });

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'Пользователь не найден',
        details: 'Пользователь был удален или деактивирован'
      });
    }

    // Проверяем текущий пароль
    const isValidPassword = await user.comparePassword(currentPassword);
    if (!isValidPassword) {
      return res.status(400).json({
        status: 'error',
        message: 'Неверный текущий пароль',
        details: 'Проверьте правильность введенного текущего пароля'
      });
    }

    // Обновляем пароль
    await user.update({ password: newPassword });

    res.json({
      status: 'success',
      message: 'Пароль успешно изменен'
    });
  } catch (error) {
    console.error('Ошибка при изменении пароля:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при изменении пароля',
      details: error.message
    });
  }
});

module.exports = router; 
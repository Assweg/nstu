const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { User } = require('../models');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Регистрация
router.post('/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Проверяем, существует ли пользователь
    const existingUser = await User.findOne({ 
      where: {
        username: username
      }
    });

    if (existingUser) {
      return res.status(400).json({ message: 'Пользователь уже существует' });
    }

    // Создаем нового пользователя
    const user = await User.create({ 
      username, 
      email,
      password_hash: password,
      role: 'user'
    });

    res.status(201).json({
      message: 'Пользователь успешно зарегистрирован',
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Ошибка при регистрации:', error);
    res.status(500).json({ message: 'Ошибка при регистрации пользователя' });
  }
});

// Вход
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    console.log('Попытка входа для пользователя:', username);

    // Ищем пользователя
    const user = await User.findOne({ 
      where: { 
        username: username,
        active: true
      },
      attributes: ['id', 'username', 'email', 'password_hash', 'role', 'active', 'created_at', 'updated_at']
    });

    console.log('Результат поиска пользователя:', user ? 'найден' : 'не найден');

    if (!user) {
      console.log('Пользователь не найден');
      return res.status(401).json({ message: 'Неверное имя пользователя или пароль' });
    }

    // Проверяем пароль
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    console.log('Результат проверки пароля:', isValidPassword ? 'верный' : 'неверный');

    if (!isValidPassword) {
      console.log('Неверный пароль');
      return res.status(401).json({ message: 'Неверное имя пользователя или пароль' });
    }

    // Создаем JWT токен
    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
        role: user.role
      },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '24h' }
    );

    console.log('Токен успешно создан');

    res.json({
      message: 'Успешная аутентификация',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Ошибка при входе:', error);
    res.status(500).json({ message: 'Ошибка при аутентификации' });
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
        message: 'Пользователь не найден'
      });
    }

    // Проверяем текущий пароль
    if (!(await user.comparePassword(currentPassword))) {
      return res.status(401).json({
        status: 'error',
        message: 'Неверный текущий пароль'
      });
    }

    // Обновляем пароль
    user.password_hash = newPassword;
    await user.save();

    res.json({
      status: 'success',
      message: 'Пароль успешно изменен'
    });
  } catch (error) {
    console.error('Ошибка при смене пароля:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка при смене пароля'
    });
  }
});

// Продление сессии
router.post('/refresh-token', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      return res.status(400).json({
        status: 'error',
        message: 'Отсутствует refresh token'
      });
    }

    // Верифицируем refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    // Проверяем существование пользователя
    const user = await User.findByPk(decoded.id);
    
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'Пользователь не найден'
      });
    }

    // Генерируем новую пару токенов
    const accessToken = jwt.sign(
      { id: user.id, username: user.username },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    const newRefreshToken = jwt.sign(
      { id: user.id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      status: 'success',
      data: {
        accessToken,
        refreshToken: newRefreshToken
      }
    });
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        status: 'error',
        message: 'Невалидный refresh token'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        status: 'error',
        message: 'Refresh token истек'
      });
    }

    console.error('Ошибка при обновлении токена:', error);
    res.status(500).json({
      status: 'error',
      message: 'Ошибка сервера'
    });
  }
});

module.exports = router; 
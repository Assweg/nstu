const app = require('./app');
const { sequelize } = require('./models');

const PORT = process.env.PORT || 5000;

// Синхронизация с базой данных и запуск сервера
sequelize.sync().then(() => {
  app.listen(PORT, () => {
    console.log(`Сервер запущен на порту ${PORT}`);
  });
}); 
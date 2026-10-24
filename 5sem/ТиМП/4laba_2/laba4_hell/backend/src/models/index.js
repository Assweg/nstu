const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5434/energy_monitoring');

const User = require('./user')(sequelize);
const Object = require('./object')(sequelize);
const Incident = require('./incident')(sequelize);
const Report = require('./report')(sequelize);

// Определение связей между моделями
Object.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user'
});

User.hasMany(Object, {
  foreignKey: 'userId',
  as: 'objects'
});

Object.hasMany(Incident, {
  foreignKey: 'objectId',
  as: 'incidents'
});

Incident.belongsTo(Object, {
  foreignKey: 'objectId',
  as: 'object'
});

Object.hasMany(Report, {
  foreignKey: 'objectId',
  as: 'reports'
});

Report.belongsTo(Object, {
  foreignKey: 'objectId',
  as: 'object'
});

Report.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user'
});

User.hasMany(Report, {
  foreignKey: 'userId',
  as: 'reports'
});

module.exports = {
  sequelize,
  User,
  Object,
  Incident,
  Report
}; 
const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Object = sequelize.define('Object', {
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true
      }
    },
    type: {
      type: DataTypes.ENUM('substation', 'powerline', 'generator', 'transformer'),
      allowNull: false,
      defaultValue: 'substation'
    },
    location: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true
      }
    },
    status: {
      type: DataTypes.ENUM('active', 'maintenance', 'inactive', 'error'),
      defaultValue: 'active'
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    lastInspection: {
      type: DataTypes.DATE,
      allowNull: true
    },
    nextInspection: {
      type: DataTypes.DATE,
      allowNull: true
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    }
  }, {
    tableName: 'objects',
    timestamps: true
  });

  Object.associate = (models) => {
    Object.belongsTo(models.User, {
      foreignKey: 'userId',
      as: 'user'
    });
    Object.hasMany(models.Report, {
      foreignKey: 'objectId',
      as: 'reports'
    });
    Object.hasMany(models.Incident, {
      foreignKey: 'objectId',
      as: 'incidents'
    });
  };

  return Object;
}; 
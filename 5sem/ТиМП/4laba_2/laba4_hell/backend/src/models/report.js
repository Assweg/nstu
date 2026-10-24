const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Report = sequelize.define('Report', {
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    type: {
      type: DataTypes.ENUM('daily', 'weekly', 'monthly', 'incident', 'maintenance'),
      defaultValue: 'daily'
    },
    generatedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    },
    status: {
      type: DataTypes.ENUM('draft', 'submitted', 'approved', 'archived'),
      defaultValue: 'draft'
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    objectId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'objects',
        key: 'id'
      }
    }
  }, {
    tableName: 'reports',
    timestamps: true
  });

  Report.associate = (models) => {
    Report.belongsTo(models.User, {
      foreignKey: 'userId',
      as: 'user'
    });
    Report.belongsTo(models.Object, {
      foreignKey: 'objectId',
      as: 'object'
    });
  };

  return Report;
}; 
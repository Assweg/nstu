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
      type: DataTypes.STRING,
      defaultValue: 'daily'
    },
    generatedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
      field: 'generated_at'
    },
    status: {
      type: DataTypes.STRING,
      defaultValue: 'draft'
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'user_id',
      references: {
        model: 'users',
        key: 'id'
      }
    },
    objectId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      field: 'object_id',
      references: {
        model: 'objects',
        key: 'id'
      }
    }
  }, {
    tableName: 'reports',
    underscored: true,
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  });

  Report.associate = (models) => {
    Report.belongsTo(models.User, {
      foreignKey: 'userId',
      as: 'user'
    });
    Report.belongsTo(models.EnergyObject, {
      foreignKey: 'objectId',
      as: 'object'
    });
  };

  return Report;
}; 
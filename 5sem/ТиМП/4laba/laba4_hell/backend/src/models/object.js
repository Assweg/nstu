const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const EnergyObject = sequelize.define('EnergyObject', {
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    type: {
      type: DataTypes.STRING,
      defaultValue: 'substation'
    },
    location: {
      type: DataTypes.STRING,
      allowNull: false
    },
    status: {
      type: DataTypes.STRING,
      defaultValue: 'active'
    },
    description: {
      type: DataTypes.TEXT
    },
    lastInspection: {
      type: DataTypes.DATE,
      field: 'last_inspection'
    },
    nextInspection: {
      type: DataTypes.DATE,
      field: 'next_inspection'
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'user_id',
      references: {
        model: 'users',
        key: 'id'
      }
    }
  }, {
    tableName: 'objects',
    underscored: true,
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  });

  EnergyObject.associate = (models) => {
    EnergyObject.belongsTo(models.User, {
      foreignKey: 'userId',
      as: 'user'
    });
    EnergyObject.hasMany(models.Incident, {
      foreignKey: 'objectId',
      as: 'incidents'
    });
    EnergyObject.hasMany(models.Report, {
      foreignKey: 'objectId',
      as: 'reports'
    });
  };

  return EnergyObject;
}; 
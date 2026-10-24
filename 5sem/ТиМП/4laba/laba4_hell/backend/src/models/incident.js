const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Incident = sequelize.define('Incident', {
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT
    },
    severity: {
      type: DataTypes.STRING,
      defaultValue: 'low'
    },
    status: {
      type: DataTypes.STRING,
      defaultValue: 'open'
    },
    reportedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
      field: 'reported_at'
    },
    resolvedAt: {
      type: DataTypes.DATE,
      field: 'resolved_at'
    },
    objectId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'object_id',
      references: {
        model: 'objects',
        key: 'id'
      }
    }
  }, {
    tableName: 'incidents',
    underscored: true,
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  });

  Incident.associate = (models) => {
    Incident.belongsTo(models.EnergyObject, {
      foreignKey: 'objectId',
      as: 'object'
    });
  };

  return Incident;
}; 
import React, { useState, useEffect } from 'react';
import { addIncident, updateIncident, getIncidents } from '../services/api';

function IncidentForm({ match }) {
  const [formData, setFormData] = useState({
    title: '',
    date: '',
    severity: 'low',
    description: '',
    status: 'new',
  });
  const [loading, setLoading] = useState(true);
  const [isEditMode, setIsEditMode] = useState(false);

  const { id } = match.params || {};

  useEffect(() => {
    if (id) {
      getIncidents()
        .then((response) => {
          const incident = response.data.find((item) => item.id === Number(id));
          if (incident) {
            setFormData(incident);
            setIsEditMode(true);
          }
        })
        .catch((err) => console.error('Ошибка при загрузке данных:', err))
        .finally(() => setLoading(false));
    } else {
      setLoading(false);
    }
  }, [id]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (isEditMode) {
      updateIncident(id, formData)
        .then(() => alert('Инцидент успешно обновлен'))
        .catch((err) => console.error('Ошибка при обновлении:', err));
    } else {
      addIncident(formData)
        .then(() => alert('Инцидент успешно добавлен'))
        .catch((err) => console.error('Ошибка при добавлении:', err));
    }
  };

  if (loading) return <p>Загрузка...</p>;

  return (
    <form onSubmit={handleSubmit}>
      <h2>{isEditMode ? 'Редактировать инцидент' : 'Добавить инцидент'}</h2>
      <div>
        <label>Название:</label>
        <input
          type="text"
          name="title"
          value={formData.title}
          onChange={handleChange}
          required
        />
      </div>
      <div>
        <label>Дата:</label>
        <input
          type="date"
          name="date"
          value={formData.date}
          onChange={handleChange}
          required
        />
      </div>
      <div>
        <label>Уровень серьезности:</label>
        <select name="severity" value={formData.severity} onChange={handleChange}>
          <option value="low">Низкий</option>
          <option value="medium">Средний</option>
          <option value="high">Высокий</option>
        </select>
      </div>
      <div>
        <label>Статус:</label>
        <select name="status" value={formData.status} onChange={handleChange}>
          <option value="new">Новый</option>
          <option value="in_progress">В процессе</option>
          <option value="resolved">Решен</option>
        </select>
      </div>
      <div>
        <label>Описание:</label>
        <textarea
          name="description"
          value={formData.description}
          onChange={handleChange}
          required
        />
      </div>
      <button type="submit">{isEditMode ? 'Обновить' : 'Добавить'}</button>
    </form>
  );
}

export default IncidentForm;
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getIncidentById, addIncident, updateIncident } from '../services/api';

function FormPage() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    title: '',
    date: '',
    severity: 'low',
    description: '',
    status: 'new',
  });

  const [errors, setErrors] = useState({});

  const [isEditMode, setIsEditMode] = useState(false);

  useEffect(() => {
    if (id) {
      getIncidentById(id)
        .then((incident) => {
          if (incident) {
            setFormData(incident);
            setIsEditMode(true);
          } else {
            console.error('Инцидент с указанным ID не найден');
          }
        })
        .catch((err) => console.error('Ошибка при загрузке данных:', err));
    }
  }, [id]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const validate = () => {
    const newErrors = {};
    if (!formData.title) newErrors.title = 'Название обязательно';
    if (!formData.date) newErrors.date = 'Дата обязательна';
    if (!formData.description) newErrors.description = 'Описание обязательно';
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!validate()) return;
  
    if (isEditMode) {
      updateIncident(id, formData)
        .then((updatedData) => {
          alert('Инцидент успешно обновлен');
          navigate('/');
        })
        .catch((err) => console.error('Ошибка при обновлении:', err));
    } else {
      addIncident(formData)
        .then(() => {
          alert('Инцидент успешно добавлен');
          navigate('/');
        })
        .catch((err) => console.error('Ошибка при добавлении:', err));
    }
  };
  
  return (
    <div className="container">
      <form onSubmit={handleSubmit}>
        <h2>{isEditMode ? 'Редактировать инцидент' : 'Добавить инцидент'}</h2>

        {}
        <div>
          <label>Название:</label>
          <input
            type="text"
            name="title"
            value={formData.title}
            onChange={handleChange}
          />
          {errors.title && <p style={{ color: 'red' }}>{errors.title}</p>}
        </div>

        {}
        <div>
          <label>Дата:</label>
          <input
            type="date"
            name="date"
            value={formData.date}
            onChange={handleChange}
          />
          {errors.date && <p style={{ color: 'red' }}>{errors.date}</p>}
        </div>

        {}
        <div>
          <label>Уровень серьезности:</label>
          <select name="severity" value={formData.severity} onChange={handleChange}>
            <option value="low">Низкий</option>
            <option value="medium">Средний</option>
            <option value="high">Высокий</option>
          </select>
        </div>

        {}
        <div>
          <label>Статус:</label>
          <select name="status" value={formData.status} onChange={handleChange}>
            <option value="new">Новый</option>
            <option value="in_progress">В процессе</option>
            <option value="resolved">Решен</option>
          </select>
        </div>

        {}
        <div>
          <label>Описание:</label>
          <textarea
            name="description"
            value={formData.description}
            onChange={handleChange}
          />
          {errors.description && <p style={{ color: 'red' }}>{errors.description}</p>}
        </div>

        {}
        <button type="submit">{isEditMode ? 'Обновить' : 'Добавить'}</button>
      </form>
    </div>
  );
}

export default FormPage;
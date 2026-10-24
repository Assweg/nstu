import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { getIncidentById } from '../services/api';

function DetailsPage() {
  const { id } = useParams();
  const [incident, setIncident] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    getIncidentById(id)
      .then((data) => {
        if (data) {
          setIncident(data);
        } else {
          setError('Инцидент не найден');
        }
        setLoading(false);
      })
      .catch((err) => {
        console.error('Ошибка при загрузке данных:', err);
        setError('Ошибка при загрузке данных');
        setLoading(false);
      });
  }, [id]);

  if (loading) {
    return <p>Загрузка...</p>;
  }

  if (error) {
    return <p>{error}</p>;
  }

  return (
    <div>
      <h2>Подробная информация об инциденте</h2>
      <p><strong>Название:</strong> {incident.title}</p>
      <p><strong>Дата:</strong> {incident.date}</p>
      <p><strong>Уровень серьезности:</strong> {incident.severity}</p>
      <p><strong>Статус:</strong> {incident.status}</p>
      <p><strong>Описание:</strong> {incident.description}</p>
    </div>
  );
}

export default DetailsPage;
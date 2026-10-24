import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { getIncidents, deleteIncident } from '../services/api';
import Header from '../components/Header';
import Footer from '../components/Footer';
import spinnerImage from './1.png';

function Spinner({ src }) {
  const spinStyle = {
    width: '500px',
    height: '500px',
    borderRadius: '50%',
    animation: 'spin 1.2s linear infinite',
    objectFit: 'cover',
    boxShadow: '0 0 8px rgba(0,0,0,0.2)',
    transition: 'transform 0.1s linear'
  };

  useEffect(() => {
    if (!document.getElementById('spin-animation')) {
      const style = document.createElement('style');
      style.id = 'spin-animation';
      style.textContent = `
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `;
      document.head.appendChild(style);
    }
  }, []);

  return (
    <div style={{ textAlign: 'center', padding: '40px' }}>
      <img
        src={src}
        alt="Загрузка..."
        style={spinStyle}
      />
      <p style={{ marginTop: '15px', fontSize: '16px', color: '#555' }}>Загрузка данных...</p>
    </div>
  );
}

function HomePage() {
  const [incidents, setIncidents] = useState([]);
  const [filter, setFilter] = useState('all');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);

    getIncidents()
      .then((response) => {
        setTimeout(() => {
          setIncidents(response.data);
          setLoading(false);
        }, 6500);
      })
      .catch((error) => {
        console.error('Ошибка при загрузке данных:', error);
        setLoading(false);
      });
  }, []);

  const handleDelete = (id) => {
    if (window.confirm('Вы уверены, что хотите удалить этот инцидент?')) {
      deleteIncident(id)
        .then(() => {
          setIncidents(incidents.filter((item) => item.id !== id));
        })
        .catch((error) => console.error('Ошибка при удалении:', error));
    }
  };

  const filteredIncidents = incidents.filter((incident) => {
    if (filter === 'all') return true;
    return incident.severity === filter;
  });

  if (loading) {
    return <Spinner src={spinnerImage} />;
  }

  return (
    <div style={styles.container}>
      <Header />
      <main style={styles.main}>
        {}
        <section style={styles.metricsContainer}>
          <div style={styles.metrics}>
            <div style={styles.metric}>
              <h3>Всего инцидентов</h3>
              <p>{incidents.length}</p>
            </div>
            <div style={styles.metric}>
              <h3>Решено</h3>
              <p>{incidents.filter((i) => i.status === 'resolved').length}</p>
            </div>
            <div style={styles.metric}>
              <h3>В процессе</h3>
              <p>{incidents.filter((i) => i.status === 'in_progress').length}</p>
            </div>
          </div>
        </section>

        {}
        <section style={styles.filters}>
          <label>
            Фильтр по уровню серьезности:
            <select value={filter} onChange={(e) => setFilter(e.target.value)}>
              <option value="all">Все</option>
              <option value="low">Низкий</option>
              <option value="medium">Средний</option>
              <option value="high">Высокий</option>
            </select>
          </label>
        </section>

        {}
        <section style={styles.incidents}>
          <h2>Текущие инциденты</h2>
          <ul>
            {filteredIncidents.map((incident) => (
              <li key={incident.id} style={styles.incident}>
                <div>
                  <Link to={`/incident/${incident.id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                    <strong>{incident.title}</strong>
                  </Link>
                  <p>Дата: {incident.date}</p>
                  <p>Статус: {incident.status}</p>
                </div>
                <div>
                  <Link to={`/edit/${incident.id}`}>
                    <button style={{ marginRight: '10px' }}>Редактировать</button>
                  </Link>
                  <button onClick={() => handleDelete(incident.id)}>Удалить</button>
                </div>
              </li>
            ))}
          </ul>
        </section>
      </main>
      <Footer />
    </div>
  );
}

const styles = {
  container: {
    display: 'flex',
    flexDirection: 'column',
    minHeight: '100vh',
  },
  main: {
    flex: 1,
    padding: '20px',
  },
  metricsContainer: {
    display: 'flex',
    justifyContent: 'center',
    marginBottom: '20px',
  },
  metrics: {
    display: 'flex',
    gap: '20px',
    alignItems: 'center',
  },
  metric: {
    background: '#fff',
    padding: '15px',
    borderRadius: '8px',
    boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
    textAlign: 'center',
    minWidth: '150px',
  },
  filters: {
    marginBottom: '20px',
  },
  incidents: {
    background: '#fff',
    padding: '20px',
    borderRadius: '8px',
    boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
  },
  incident: {
    background: '#f9f9f9',
    margin: '10px 0',
    padding: '15px',
    borderRadius: '8px',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
};

export default HomePage;
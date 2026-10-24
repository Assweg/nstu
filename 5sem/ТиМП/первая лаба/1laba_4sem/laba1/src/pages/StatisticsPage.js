import React, { useEffect, useState } from 'react';
import { getIncidents } from '../services/api';
import { Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

function StatisticsPage() {
  const [stats, setStats] = useState({ total: 0, resolved: 0, inProgress: 0 });

  useEffect(() => {
    getIncidents()
      .then((response) => {
        const incidents = response.data;
        const resolved = incidents.filter((i) => i.status === 'resolved').length;
        const inProgress = incidents.filter((i) => i.status === 'in_progress').length;
        setStats({
          total: incidents.length,
          resolved,
          inProgress,
        });
      })
      .catch((error) => console.error('Ошибка при загрузке данных:', error));
  }, []);

  const data = {
    labels: ['Всего', 'Решено', 'В процессе'],
    datasets: [
      {
        label: 'Количество инцидентов',
        data: [stats.total, stats.resolved, stats.inProgress],
        backgroundColor: ['#007bff', '#28a745', '#ffc107'],
      },
    ],
  };

  return (
    <div style={styles.container}>
      <h1>Статистика инцидентов</h1>
      <Bar data={data} options={{ responsive: true }} />
    </div>
  );
}

const styles = {
  container: {
    padding: '20px',
  },
};

export default StatisticsPage;
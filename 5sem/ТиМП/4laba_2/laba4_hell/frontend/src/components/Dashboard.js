import React, { useState, useEffect } from 'react';
import {
  Container,
  Grid,
  Paper,
  Typography,
  Card,
  CardContent,
  Box,
  CircularProgress
} from '@mui/material';
import {
  Warning as WarningIcon,
  CheckCircle as CheckCircleIcon,
  Error as ErrorIcon
} from '@mui/icons-material';
import { dashboard } from '../services/api';
import { useNavigate } from 'react-router-dom';

const Dashboard = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        const [statsResponse, incidentsResponse] = await Promise.all([
          dashboard.getStats(),
          dashboard.getRecentIncidents()
        ]);
        
        const stats = statsResponse.data.data;
        const incidents = incidentsResponse.data.data;

        // Преобразуем данные в нужный формат
        const objectStatusCounts = {
          normal: 0,
          warning: 0,
          critical: 0
        };

        // Подсчитываем количество объектов по статусу
        if (stats.objectsByStatus) {
          Object.entries(stats.objectsByStatus).forEach(([status, count]) => {
            switch (status) {
              case 'active':
                objectStatusCounts.normal = count;
                break;
              case 'maintenance':
                objectStatusCounts.warning = count;
                break;
              case 'error':
                objectStatusCounts.critical = count;
                break;
              default:
                break;
            }
          });
        }

        setData({
          totalObjects: stats.totalObjects || 0,
          activeIncidents: stats.activeIncidents || 0,
          objectsStatus: objectStatusCounts,
          recentIncidents: incidents.map(incident => ({
            id: incident.id,
            title: incident.title,
            severity: incident.severity,
            date: incident.reportedAt
          })) || []
        });
      } catch (err) {
        console.error('Ошибка при загрузке данных:', err);
        if (err.response?.status === 401) {
          localStorage.removeItem('token');
          navigate('/login');
        } else {
          setError(err.response?.data?.message || 'Ошибка при подключении к серверу');
        }
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, [navigate]);

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="80vh">
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return (
      <Container>
        <Typography color="error" variant="h6" align="center">
          {error}
        </Typography>
      </Container>
    );
  }

  if (!data) {
    return (
      <Container>
        <Typography color="error" variant="h6" align="center">
          Нет данных для отображения
        </Typography>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg">
      <Typography variant="h4" gutterBottom>
        Панель управления
      </Typography>

      <Grid container spacing={3}>
        {/* Общая статистика */}
        <Grid item xs={12} md={4}>
          <Paper elevation={3} sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom>
              Всего объектов
            </Typography>
            <Typography variant="h3">
              {data.totalObjects}
            </Typography>
          </Paper>
        </Grid>

        <Grid item xs={12} md={4}>
          <Paper elevation={3} sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom>
              Активные инциденты
            </Typography>
            <Typography variant="h3" color="error">
              {data.activeIncidents}
            </Typography>
          </Paper>
        </Grid>

        <Grid item xs={12} md={4}>
          <Paper elevation={3} sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom>
              Статус объектов
            </Typography>
            <Grid container spacing={1}>
              <Grid item xs={4}>
                <Box display="flex" alignItems="center">
                  <CheckCircleIcon color="success" />
                  <Typography variant="body1" ml={1}>
                    {data.objectsStatus.normal}
                  </Typography>
                </Box>
              </Grid>
              <Grid item xs={4}>
                <Box display="flex" alignItems="center">
                  <WarningIcon color="warning" />
                  <Typography variant="body1" ml={1}>
                    {data.objectsStatus.warning}
                  </Typography>
                </Box>
              </Grid>
              <Grid item xs={4}>
                <Box display="flex" alignItems="center">
                  <ErrorIcon color="error" />
                  <Typography variant="body1" ml={1}>
                    {data.objectsStatus.critical}
                  </Typography>
                </Box>
              </Grid>
            </Grid>
          </Paper>
        </Grid>

        {/* Последние инциденты */}
        <Grid item xs={12}>
          <Paper elevation={3} sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom>
              Последние инциденты
            </Typography>
            <Grid container spacing={2}>
              {data.recentIncidents.length > 0 ? (
                data.recentIncidents.map((incident) => (
                  <Grid item xs={12} sm={6} key={incident.id}>
                    <Card>
                      <CardContent>
                        <Typography variant="h6" gutterBottom>
                          {incident.title}
                        </Typography>
                        <Typography color="textSecondary">
                          Дата: {new Date(incident.date).toLocaleDateString()}
                        </Typography>
                        <Typography
                          color={
                            incident.severity === 'high'
                              ? 'error'
                              : incident.severity === 'medium'
                              ? 'warning.main'
                              : 'success.main'
                          }
                        >
                          Приоритет: {
                            incident.severity === 'high'
                              ? 'Высокий'
                              : incident.severity === 'medium'
                              ? 'Средний'
                              : 'Низкий'
                          }
                        </Typography>
                      </CardContent>
                    </Card>
                  </Grid>
                ))
              ) : (
                <Grid item xs={12}>
                  <Typography variant="body1" align="center">
                    Нет активных инцидентов
                  </Typography>
                </Grid>
              )}
            </Grid>
          </Paper>
        </Grid>
      </Grid>
    </Container>
  );
};

export default Dashboard; 
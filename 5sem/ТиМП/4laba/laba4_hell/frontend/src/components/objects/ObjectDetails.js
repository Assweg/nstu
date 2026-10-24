import React, { useState, useEffect } from 'react';
import { 
  Container, 
  Paper, 
  Typography, 
  Grid, 
  Card, 
  CardContent,
  Button,
  Box,
  CircularProgress
} from '@mui/material';
import { useParams } from 'react-router-dom';

const ObjectDetails = () => {
  const { id } = useParams();
  const [object, setObject] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchObjectDetails = async () => {
      try {
        const response = await fetch(`http://localhost:5002/api/objects/${id}`);
        const data = await response.json();
        
        if (response.ok) {
          setObject(data);
        } else {
          setError(data.message || 'Ошибка при загрузке данных объекта');
        }
      } catch (err) {
        setError('Ошибка при подключении к серверу');
      } finally {
        setLoading(false);
      }
    };

    fetchObjectDetails();
  }, [id]);

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

  if (!object) {
    return (
      <Container>
        <Typography variant="h6" align="center">
          Объект не найден
        </Typography>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg">
      <Paper elevation={3} sx={{ p: 3, mt: 3 }}>
        <Typography variant="h4" gutterBottom>
          {object.name}
        </Typography>
        
        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Основная информация
                </Typography>
                <Typography><strong>Тип объекта:</strong> {object.type}</Typography>
                <Typography><strong>Адрес:</strong> {object.address}</Typography>
                <Typography><strong>Статус:</strong> {object.status}</Typography>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} md={6}>
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Технические характеристики
                </Typography>
                <Typography><strong>Мощность:</strong> {object.power} МВт</Typography>
                <Typography><strong>Год постройки:</strong> {object.buildYear}</Typography>
                <Typography><strong>Последняя проверка:</strong> {new Date(object.lastInspection).toLocaleDateString()}</Typography>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12}>
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Показатели мониторинга
                </Typography>
                <Grid container spacing={2}>
                  {object.metrics && object.metrics.map((metric, index) => (
                    <Grid item xs={12} sm={6} md={4} key={index}>
                      <Paper elevation={1} sx={{ p: 2 }}>
                        <Typography variant="subtitle1">{metric.name}</Typography>
                        <Typography variant="h6">{metric.value} {metric.unit}</Typography>
                        <Typography color={metric.status === 'normal' ? 'success.main' : 'error.main'}>
                          {metric.status}
                        </Typography>
                      </Paper>
                    </Grid>
                  ))}
                </Grid>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        <Box sx={{ mt: 3, display: 'flex', gap: 2 }}>
          <Button variant="contained" color="primary">
            Редактировать
          </Button>
          <Button variant="outlined" color="secondary">
            История изменений
          </Button>
        </Box>
      </Paper>
    </Container>
  );
};

export default ObjectDetails; 
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
  Box,
  CircularProgress,
  Chip,
  IconButton,
  Tooltip
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Refresh as RefreshIcon
} from '@mui/icons-material';
import { toast } from 'react-toastify';
import api from '../../services/api';

const Objects = () => {
  const navigate = useNavigate();
  const [objects, setObjects] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchObjects = async () => {
    setLoading(true);
    try {
      const response = await api.objects.getAll();
      // Проверяем наличие данных в ответе
      if (response?.data?.status === 'success' && Array.isArray(response.data.data)) {
        setObjects(response.data.data);
      } else {
        setObjects([]);
        console.error('Неверный формат данных:', response);
      }
    } catch (error) {
      console.error('Ошибка при загрузке объектов:', error);
      toast.error(error.message || 'Ошибка при загрузке объектов');
      setObjects([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchObjects();
  }, []);

  const handleDelete = async (id) => {
    if (window.confirm('Вы уверены, что хотите удалить этот объект?')) {
      try {
        await api.objects.delete(id);
        toast.success('Объект успешно удален');
        fetchObjects();
      } catch (error) {
        toast.error(error.message || 'Ошибка при удалении объекта');
      }
    }
  };

  const getStatusColor = (status) => {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'success';
      case 'maintenance':
        return 'warning';
      case 'inactive':
        return 'error';
      case 'error':
        return 'error';
      default:
        return 'default';
    }
  };

  const getStatusLabel = (status) => {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Активный';
      case 'maintenance':
        return 'На обслуживании';
      case 'inactive':
        return 'Неактивный';
      case 'error':
        return 'Ошибка';
      default:
        return status || 'Неизвестно';
    }
  };

  const getTypeLabel = (type) => {
    switch (type?.toLowerCase()) {
      case 'substation':
        return 'Подстанция';
      case 'powerline':
        return 'Линия электропередач';
      case 'generator':
        return 'Генератор';
      case 'transformer':
        return 'Трансформатор';
      default:
        return type || 'Неизвестно';
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="80vh">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Container maxWidth="lg">
      <Box sx={{ mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h4">
          Энергообъекты
        </Typography>
        <Box>
          <Tooltip title="Обновить список">
            <IconButton onClick={fetchObjects} sx={{ mr: 1 }}>
              <RefreshIcon />
            </IconButton>
          </Tooltip>
          <Button
            variant="contained"
            color="primary"
            startIcon={<AddIcon />}
            onClick={() => navigate('/objects/new')}
          >
            Добавить объект
          </Button>
        </Box>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Название</TableCell>
              <TableCell>Тип</TableCell>
              <TableCell>Местоположение</TableCell>
              <TableCell>Статус</TableCell>
              <TableCell>Действия</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {objects.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} align="center">
                  <Typography variant="body1" sx={{ py: 2 }}>
                    Нет доступных объектов
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              objects.map((object) => (
                <TableRow key={object.id}>
                  <TableCell>{object.name}</TableCell>
                  <TableCell>{getTypeLabel(object.type)}</TableCell>
                  <TableCell>{object.location}</TableCell>
                  <TableCell>
                    <Chip
                      label={getStatusLabel(object.status)}
                      color={getStatusColor(object.status)}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    <Tooltip title="Редактировать">
                      <IconButton
                        size="small"
                        onClick={() => navigate(`/objects/${object.id}/edit`)}
                        sx={{ mr: 1 }}
                      >
                        <EditIcon />
                      </IconButton>
                    </Tooltip>
                    <Tooltip title="Удалить">
                      <IconButton
                        size="small"
                        color="error"
                        onClick={() => handleDelete(object.id)}
                      >
                        <DeleteIcon />
                      </IconButton>
                    </Tooltip>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>
    </Container>
  );
};

export default Objects; 
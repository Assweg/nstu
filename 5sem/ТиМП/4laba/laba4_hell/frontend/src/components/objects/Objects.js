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
  Tooltip,
  Pagination,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Grid
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Refresh as RefreshIcon
} from '@mui/icons-material';
import { toast } from 'react-toastify';
import api from '../../services/api';
import { Link } from 'react-router-dom';

const Objects = () => {
  const navigate = useNavigate();
  const [objects, setObjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [filters, setFilters] = useState({
    type: '',
    status: ''
  });

  const fetchObjects = async () => {
    try {
      const queryParams = new URLSearchParams({
        page,
        limit: 10,
        ...(filters.type && { type: filters.type }),
        ...(filters.status && { status: filters.status })
      });

      const response = await fetch(`http://localhost:5002/api/objects?${queryParams}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      const data = await response.json();
      
      if (response.ok) {
        setObjects(data.data);
        setTotalPages(data.pagination.totalPages);
      } else {
        setError(data.message || 'Ошибка при загрузке объектов');
      }
    } catch (err) {
      setError('Ошибка при подключении к серверу');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchObjects();
  }, [page, filters]);

  const handlePageChange = (event, value) => {
    setPage(value);
  };

  const handleFilterChange = (event) => {
    setFilters({
      ...filters,
      [event.target.name]: event.target.value
    });
    setPage(1); // Сброс на первую страницу при изменении фильтров
  };

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

  if (error) {
    return (
      <Container>
        <Typography color="error" variant="h6" align="center">
          {error}
        </Typography>
      </Container>
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

      {/* Фильтры */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <FormControl fullWidth>
            <InputLabel>Тип объекта</InputLabel>
            <Select
              name="type"
              value={filters.type}
              onChange={handleFilterChange}
              label="Тип объекта"
            >
              <MenuItem value="">Все</MenuItem>
              <MenuItem value="substation">Подстанция</MenuItem>
              <MenuItem value="powerline">ЛЭП</MenuItem>
              <MenuItem value="generator">Генератор</MenuItem>
              <MenuItem value="transformer">Трансформатор</MenuItem>
            </Select>
          </FormControl>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <FormControl fullWidth>
            <InputLabel>Статус</InputLabel>
            <Select
              name="status"
              value={filters.status}
              onChange={handleFilterChange}
              label="Статус"
            >
              <MenuItem value="">Все</MenuItem>
              <MenuItem value="active">Активен</MenuItem>
              <MenuItem value="maintenance">На обслуживании</MenuItem>
              <MenuItem value="inactive">Неактивен</MenuItem>
              <MenuItem value="error">Ошибка</MenuItem>
            </Select>
          </FormControl>
        </Grid>
      </Grid>

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

      {/* Пагинация */}
      <Box sx={{ mt: 3, display: 'flex', justifyContent: 'center' }}>
        <Pagination
          count={totalPages}
          page={page}
          onChange={handlePageChange}
          color="primary"
        />
      </Box>
    </Container>
  );
};

export default Objects; 
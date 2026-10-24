import React, { useState, useEffect } from 'react';
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
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  MenuItem
} from '@mui/material';
import { Add as AddIcon, Download as DownloadIcon } from '@mui/icons-material';

const Reports = () => {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [newReport, setNewReport] = useState({
    title: '',
    type: 'monthly',
    objectId: '',
    startDate: '',
    endDate: ''
  });

  useEffect(() => {
    const fetchReports = async () => {
      try {
        const response = await fetch('http://localhost:5002/api/reports', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        const data = await response.json();
        
        if (response.ok) {
          setReports(data);
        } else {
          setError(data.message || 'Ошибка при загрузке отчетов');
        }
      } catch (err) {
        setError('Ошибка при подключении к серверу');
      } finally {
        setLoading(false);
      }
    };

    fetchReports();
  }, []);

  const handleOpenDialog = () => {
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setNewReport({
      title: '',
      type: 'monthly',
      objectId: '',
      startDate: '',
      endDate: ''
    });
  };

  const handleChange = (e) => {
    setNewReport({
      ...newReport,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch('http://localhost:5002/api/reports', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify(newReport)
      });

      if (response.ok) {
        handleCloseDialog();
        // Перезагрузка списка отчетов
        const updatedResponse = await fetch('http://localhost:5002/api/reports', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        const updatedData = await updatedResponse.json();
        setReports(updatedData);
      } else {
        const data = await response.json();
        alert(data.message || 'Ошибка при создании отчета');
      }
    } catch (err) {
      alert('Ошибка при подключении к серверу');
    }
  };

  const handleDownload = async (reportId) => {
    try {
      const response = await fetch(`http://localhost:5002/api/reports/${reportId}/download`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });

      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `report-${reportId}.pdf`;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
      } else {
        const data = await response.json();
        alert(data.message || 'Ошибка при скачивании отчета');
      }
    } catch (err) {
      alert('Ошибка при подключении к серверу');
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
          Отчеты
        </Typography>
        <Button
          variant="contained"
          color="primary"
          startIcon={<AddIcon />}
          onClick={handleOpenDialog}
        >
          Создать отчет
        </Button>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Название</TableCell>
              <TableCell>Тип</TableCell>
              <TableCell>Объект</TableCell>
              <TableCell>Дата создания</TableCell>
              <TableCell>Статус</TableCell>
              <TableCell>Действия</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {reports.length > 0 ? (
              reports.map((report) => (
              <TableRow key={report.id}>
                <TableCell>{report.title}</TableCell>
                <TableCell>
                  {report.type === 'monthly' ? 'Ежемесячный' : 
                   report.type === 'quarterly' ? 'Квартальный' : 
                   report.type === 'yearly' ? 'Годовой' : report.type}
                </TableCell>
                <TableCell>{report.objectName}</TableCell>
                <TableCell>{new Date(report.createdAt).toLocaleString()}</TableCell>
                <TableCell>
                  {report.status === 'completed' ? 'Готов' : 'В обработке'}
                </TableCell>
                <TableCell>
                  <Button
                    variant="outlined"
                    size="small"
                    startIcon={<DownloadIcon />}
                    onClick={() => handleDownload(report.id)}
                    disabled={report.status !== 'completed'}
                  >
                    Скачать
                  </Button>
                </TableCell>
              </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={6} align="center">
                  <Typography variant="body1">
                    Нет доступных отчетов
                  </Typography>
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>

      <Dialog open={openDialog} onClose={handleCloseDialog}>
        <DialogTitle>Создать отчет</DialogTitle>
        <DialogContent>
          <Box component="form" sx={{ mt: 2 }}>
            <TextField
              fullWidth
              label="Название"
              name="title"
              value={newReport.title}
              onChange={handleChange}
              margin="normal"
              required
            />
            <TextField
              fullWidth
              select
              label="Тип отчета"
              name="type"
              value={newReport.type}
              onChange={handleChange}
              margin="normal"
              required
            >
              <MenuItem value="monthly">Ежемесячный</MenuItem>
              <MenuItem value="quarterly">Квартальный</MenuItem>
              <MenuItem value="yearly">Годовой</MenuItem>
            </TextField>
            <TextField
              fullWidth
              label="ID объекта"
              name="objectId"
              value={newReport.objectId}
              onChange={handleChange}
              margin="normal"
              required
            />
            <TextField
              fullWidth
              label="Дата начала"
              name="startDate"
              type="date"
              value={newReport.startDate}
              onChange={handleChange}
              margin="normal"
              required
              InputLabelProps={{
                shrink: true,
              }}
            />
            <TextField
              fullWidth
              label="Дата окончания"
              name="endDate"
              type="date"
              value={newReport.endDate}
              onChange={handleChange}
              margin="normal"
              required
              InputLabelProps={{
                shrink: true,
              }}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>Отмена</Button>
          <Button onClick={handleSubmit} variant="contained" color="primary">
            Создать
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default Reports; 
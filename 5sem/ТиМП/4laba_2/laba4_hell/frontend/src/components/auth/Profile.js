import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  TextField,
  Button,
  CircularProgress,
  Divider
} from '@mui/material';
import { toast } from 'react-toastify';
import api from '../../services/api';

const Profile = () => {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [userData, setUserData] = useState({
    username: '',
    email: '',
    currentPassword: '',
    newPassword: '',
    confirmNewPassword: ''
  });

  useEffect(() => {
    loadUserData();
  }, []);

  const loadUserData = async () => {
    try {
      const response = await api.auth.getProfile();
      setUserData(prevData => ({
        ...prevData,
        username: response.data.username,
        email: response.data.email || ''
      }));
    } catch (error) {
      toast.error('Ошибка при загрузке профиля');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    setUserData({
      ...userData,
      [e.target.name]: e.target.value
    });
  };

  const handleUpdateProfile = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await api.auth.updateProfile({
        username: userData.username,
        email: userData.email
      });
      toast.success('Профиль успешно обновлен');
    } catch (error) {
      toast.error(error.message || 'Ошибка при обновлении профиля');
    } finally {
      setSaving(false);
    }
  };

  const handleChangePassword = async (e) => {
    e.preventDefault();
    if (userData.newPassword !== userData.confirmNewPassword) {
      toast.error('Новые пароли не совпадают');
      return;
    }

    setSaving(true);
    try {
      await api.auth.changePassword({
        currentPassword: userData.currentPassword,
        newPassword: userData.newPassword
      });
      setUserData(prevData => ({
        ...prevData,
        currentPassword: '',
        newPassword: '',
        confirmNewPassword: ''
      }));
      toast.success('Пароль успешно изменен');
    } catch (error) {
      toast.error(error.message || 'Ошибка при изменении пароля');
    } finally {
      setSaving(false);
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
    <Container maxWidth="sm">
      <Paper elevation={3} sx={{ p: 4, mt: 4 }}>
        <Typography variant="h4" gutterBottom>
          Профиль пользователя
        </Typography>
        
        <form onSubmit={handleUpdateProfile}>
          <TextField
            fullWidth
            label="Имя пользователя"
            name="username"
            value={userData.username}
            onChange={handleChange}
            margin="normal"
            disabled={saving}
          />
          <TextField
            fullWidth
            label="Email"
            name="email"
            type="email"
            value={userData.email}
            onChange={handleChange}
            margin="normal"
            disabled={saving}
          />
          <Button
            type="submit"
            variant="contained"
            color="primary"
            fullWidth
            sx={{ mt: 2 }}
            disabled={saving}
          >
            {saving ? <CircularProgress size={24} /> : 'Обновить профиль'}
          </Button>
        </form>

        <Divider sx={{ my: 4 }} />

        <Typography variant="h5" gutterBottom>
          Изменить пароль
        </Typography>
        
        <form onSubmit={handleChangePassword}>
          <TextField
            fullWidth
            label="Текущий пароль"
            name="currentPassword"
            type="password"
            value={userData.currentPassword}
            onChange={handleChange}
            margin="normal"
            disabled={saving}
          />
          <TextField
            fullWidth
            label="Новый пароль"
            name="newPassword"
            type="password"
            value={userData.newPassword}
            onChange={handleChange}
            margin="normal"
            disabled={saving}
          />
          <TextField
            fullWidth
            label="Подтвердите новый пароль"
            name="confirmNewPassword"
            type="password"
            value={userData.confirmNewPassword}
            onChange={handleChange}
            margin="normal"
            disabled={saving}
          />
          <Button
            type="submit"
            variant="contained"
            color="primary"
            fullWidth
            sx={{ mt: 2 }}
            disabled={saving}
          >
            {saving ? <CircularProgress size={24} /> : 'Изменить пароль'}
          </Button>
        </form>
      </Paper>
    </Container>
  );
};

export default Profile; 
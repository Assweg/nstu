import React, { useEffect, useState } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import api from '../../services/api';
import { CircularProgress, Box } from '@mui/material';

const PrivateRoute = ({ children }) => {
  const location = useLocation();
  const [isLoading, setIsLoading] = useState(true);
  const [isAuth, setIsAuth] = useState(false);

  useEffect(() => {
    const checkAuth = async () => {
      try {
        // Проверяем наличие и валидность токена
        if (!api.isAuthenticated()) {
          throw new Error('Не авторизован');
        }

        // Проверяем валидность токена через запрос к API
        await api.auth.getProfile();
        setIsAuth(true);
      } catch (error) {
        console.error('Ошибка проверки аутентификации:', error);
        setIsAuth(false);
        // Очищаем токены при ошибке
        api.auth.logout();
      } finally {
        setIsLoading(false);
      }
    };

    checkAuth();
  }, []);

  if (isLoading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="100vh">
        <CircularProgress />
      </Box>
    );
  }

  if (!isAuth) {
    // Сохраняем текущий путь для редиректа после авторизации
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return children;
};

export default PrivateRoute; 
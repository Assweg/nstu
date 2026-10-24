import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import api from '../../services/api';

const PrivateRoute = ({ children }) => {
  const location = useLocation();
  const isAuthenticated = api.isAuthenticated();
  
  if (!isAuthenticated) {
    // Сохраняем текущий путь для редиректа после авторизации
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return children;
};

export default PrivateRoute; 
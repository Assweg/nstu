import axios from 'axios';

const API_URL = process.env.NODE_ENV === 'production' 
  ? '/api'
  : 'http://localhost:5002/api';

// Создаем экземпляр axios с базовыми настройками
const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json'
  },
  withCredentials: true
});

// Функция для получения токена
const getAuthToken = () => localStorage.getItem('token');

// Функция для установки токена
export const setAuthToken = (token) => {
  if (token) {
    localStorage.setItem('token', token);
    api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  } else {
    localStorage.removeItem('token');
    delete api.defaults.headers.common['Authorization'];
  }
};

// Инициализация токена при загрузке
const token = getAuthToken();
if (token) {
  api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
}

// Перехватчик для добавления токена к запросам
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Перехватчик для обработки ответов и обновления токена
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Проверяем наличие ответа от сервера
    if (!error.response) {
      return Promise.reject({
        status: 'error',
        message: 'Ошибка сети. Проверьте подключение к интернету.'
      });
    }

    // Если ошибка 401 и это не запрос на обновление токена
    if (error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = localStorage.getItem('refreshToken');
        if (!refreshToken) {
          throw new Error('Отсутствует refresh token');
        }

        const response = await axios.post(`${API_URL}/auth/refresh-token`, {
          refreshToken
        });

        if (response.data.status === 'success' && response.data.data) {
          const { accessToken, refreshToken: newRefreshToken } = response.data.data;

          // Сохраняем новые токены
          localStorage.setItem('token', accessToken);
          localStorage.setItem('refreshToken', newRefreshToken);

          // Повторяем оригинальный запрос с новым токеном
          originalRequest.headers.Authorization = `Bearer ${accessToken}`;
          return api(originalRequest);
        } else {
          throw new Error('Неверный формат ответа при обновлении токена');
        }
      } catch (error) {
        // Если не удалось обновить токен, выходим из системы
        try {
          localStorage.removeItem('token');
          localStorage.removeItem('refreshToken');
          window.location.href = '/login';
        } catch (e) {
          console.error('Ошибка при очистке данных авторизации:', e);
      }
        return Promise.reject({
          status: 'error',
          message: 'Сессия истекла. Пожалуйста, войдите снова.'
        });
    }
    }

    // Возвращаем ошибку в стандартном формате
    return Promise.reject({
      status: 'error',
      message: error.response.data.message || 'Произошла ошибка при выполнении запроса'
    });
  }
);

// Функция для проверки авторизации
export const isAuthenticated = () => {
  const token = getAuthToken();
  if (!token) return false;
  
  try {
    // Декодируем JWT токен
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
      return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));

    const { exp } = JSON.parse(jsonPayload);
    
    // Проверяем срок действия токена
    if (exp * 1000 < Date.now()) {
      localStorage.removeItem('token');
      localStorage.removeItem('refreshToken');
      return false;
    }
    
    return true;
  } catch (error) {
    console.error('Ошибка при проверке токена:', error);
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    return false;
  }
};

// API endpoints
const auth = {
  register: async (userData) => {
    try {
      const response = await api.post('/auth/register', userData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  
  login: async (credentials) => {
    try {
      const response = await api.post('/auth/login', credentials);
      if (response.data.token) {
        localStorage.setItem('token', response.data.token);
      }
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
  },

  getProfile: () => api.get('/auth/profile'),
  updateProfile: (data) => api.put('/auth/profile', data),
  changePassword: (data) => api.put('/auth/change-password', data)
};

const objects = {
  getAll: async (params = {}) => {
    try {
      const response = await api.get('/objects', { params });
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  
  getById: async (id) => {
    try {
      const response = await api.get(`/objects/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  
  create: async (data) => {
    try {
      const response = await api.post('/objects', data);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  
  update: async (id, data) => {
    try {
      const response = await api.put(`/objects/${id}`, data);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  
  delete: async (id) => {
    try {
      const response = await api.delete(`/objects/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }
};

const incidents = {
  getAll: async () => {
    try {
      const response = await api.get('/incidents');
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  
  create: async (data) => {
    try {
      const response = await api.post('/incidents', data);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  
  update: async (id, data) => {
    try {
      const response = await api.put(`/incidents/${id}`, data);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  
  delete: async (id) => {
    try {
      const response = await api.delete(`/incidents/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }
};

const reports = {
  getAll: async () => {
    try {
      const response = await api.get('/reports');
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  
  create: async (data) => {
    try {
      const response = await api.post('/reports', data);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  
  download: async (id) => {
    try {
      const response = await api.get(`/reports/${id}/download`, {
        responseType: 'blob'
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }
};

export const dashboard = {
  getStats: () => api.get('/dashboard/stats'),
  getRecentIncidents: () => api.get('/dashboard/recent-incidents'),
  getRecentReports: () => api.get('/dashboard/recent-reports')
};

export default {
  auth,
  objects,
  incidents,
  reports,
  dashboard,
  isAuthenticated
}; 
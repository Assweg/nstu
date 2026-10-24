import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5002';

// Создаем экземпляр axios с базовыми настройками
// Автоматическая сериализация/десериализация через axios
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

// Добавляем перехватчик для добавления токена к запросам
api.interceptors.request.use(
  (config) => {
    const token = getAuthToken();
    if (token && !config.headers.Authorization) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Добавляем перехватчик для обработки ошибок
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      // Если сервер вернул ошибку 401 (неавторизован), очищаем токен
      if (error.response.status === 401) {
        setAuthToken(null);
        // Перенаправляем на страницу входа только если мы не на ней
        if (!window.location.pathname.includes('/login')) {
          window.location.href = '/login';
        }
      }
      return Promise.reject(error.response.data);
    }
    return Promise.reject(error);
  }
);

// Функция для проверки авторизации
export const isAuthenticated = () => {
  return !!getAuthToken();
};

// Сериализация
export const auth = {
  login: async (username, password) => {
    const response = await api.post('/api/auth/login', { username, password });
    // Десериализация
    if (response.data.token) {
      setAuthToken(response.data.token);
    }
    return response;
  },
  register: async (username, password) => {
    const response = await api.post('/api/auth/register', { username, password });
    if (response.data.token) {
      setAuthToken(response.data.token);
    }
    return response;
  },
  logout: () => {
    setAuthToken(null);
    window.location.href = '/login';
  },
  getProfile: () => api.get('/api/auth/profile'),
  updateProfile: (data) => api.put('/api/auth/profile', data),
  changePassword: (data) => api.put('/api/auth/change-password', data)
};

export const objects = {
  getAll: () => api.get('/api/objects'),
  getOne: (id) => api.get(`/api/objects/${id}`),
  create: (data) => api.post('/api/objects', data),
  update: (id, data) => api.put(`/api/objects/${id}`, data),
  delete: (id) => api.delete(`/api/objects/${id}`)
};

export const incidents = {
  getAll: () => api.get('/api/incidents'),
  getOne: (id) => api.get(`/api/incidents/${id}`),
  create: (data) => api.post('/api/incidents', data),
  update: (id, data) => api.put(`/api/incidents/${id}`, data),
  delete: (id) => api.delete(`/api/incidents/${id}`)
};

export const reports = {
  getAll: () => api.get('/api/reports'),
  getOne: (id) => api.get(`/api/reports/${id}`),
  create: (data) => api.post('/api/reports', data),
  update: (id, data) => api.put(`/api/reports/${id}`, data),
  delete: (id) => api.delete(`/api/reports/${id}`),
  download: async (id) => {
    try {
      const response = await api.get(`/api/reports/${id}/download`, {
        responseType: 'blob'
      });
      
      // Создаем ссылку для скачивания
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `report_${id}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
      
      return response;
    } catch (error) {
      console.error('Ошибка при скачивании отчета:', error);
      throw error;
    }
  }
};

export const dashboard = {
  getStats: () => api.get('/api/dashboard/stats'),
  getRecentIncidents: () => api.get('/api/dashboard/recent-incidents'),
  getRecentReports: () => api.get('/api/dashboard/recent-reports')
};

export default {
  auth,
  objects,
  incidents,
  reports,
  dashboard,
  isAuthenticated
}; 
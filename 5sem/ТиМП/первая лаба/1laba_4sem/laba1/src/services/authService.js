import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:7431',
});

export const login = async (username, password) => {
  const response = await api.get('/users');
  const users = response.data;
  const user = users.find(
    (u) => u.username === username && u.password === password
  );
  if (!user) throw new Error('Invalid credentials');
  return user;
};

export const register = async (userData) => {
  const response = await api.get('/users');
  const users = response.data;
  if (users.some((u) => u.username === userData.username)) {
    throw new Error('Username already exists');
  }
  await api.post('/users', { ...userData, id: Date.now() });
};
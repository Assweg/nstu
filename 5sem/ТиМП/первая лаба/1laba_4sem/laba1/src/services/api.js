import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:7431',
});

export const getIncidents = () => api.get('/incidents');
export const addIncident = (data) => api.post('/incidents', data);
export const updateIncident = (id, data) => api.put(`/incidents/${id}`, data);
export const deleteIncident = (id) => api.delete(`/incidents/${id}`);
//export const getIncidentById = (id) => api.get(`/incidents/${id}`);

export const getIncidentById = async (id) => {
  try {
    const response = await api.get(`/incidents/${id}`);
    return response.data;
  } catch (error) {
    console.error('Ошибка при получении инцидента:', error);
    throw error;
  }
};
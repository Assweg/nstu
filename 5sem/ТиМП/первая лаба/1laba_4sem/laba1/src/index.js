import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { IncidentProvider } from './context/IncidentContext';
import './App.css';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <IncidentProvider>
    <App />
  </IncidentProvider>
);
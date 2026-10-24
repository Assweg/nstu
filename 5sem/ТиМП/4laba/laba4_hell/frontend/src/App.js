import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

import Layout from './components/Layout';
import Login from './components/auth/Login';
import Register from './components/auth/Register';
import Profile from './components/auth/Profile';
import Dashboard from './components/Dashboard';
import Objects from './components/objects/Objects';
import ObjectForm from './components/objects/ObjectForm';
import Incidents from './components/incidents/Incidents';
import Reports from './components/reports/Reports';
import PrivateRoute from './components/auth/PrivateRoute';

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <ToastContainer 
          position="top-right" 
          autoClose={3000}
          hideProgressBar={false}
          newestOnTop
          closeOnClick
          rtl={false}
          pauseOnFocusLoss
          draggable
          pauseOnHover
        />
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/" element={<Layout />}>
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route
              path="dashboard"
              element={
                <PrivateRoute>
                  <Dashboard />
                </PrivateRoute>
              }
            />
            <Route
              path="objects"
              element={
                <PrivateRoute>
                  <Objects />
                </PrivateRoute>
              }
            />
            <Route
              path="objects/new"
              element={
                <PrivateRoute>
                  <ObjectForm />
                </PrivateRoute>
              }
            />
            <Route
              path="objects/:id/edit"
              element={
                <PrivateRoute>
                  <ObjectForm />
                </PrivateRoute>
              }
            />
            <Route
              path="incidents"
              element={
                <PrivateRoute>
                  <Incidents />
                </PrivateRoute>
              }
            />
            <Route
              path="reports"
              element={
                <PrivateRoute>
                  <Reports />
                </PrivateRoute>
              }
            />
            <Route
              path="profile"
              element={
                <PrivateRoute>
                  <Profile />
                </PrivateRoute>
              }
            />
          </Route>
        </Routes>
      </Router>
    </ThemeProvider>
  );
}

export default App; 
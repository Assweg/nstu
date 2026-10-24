import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { login } from '../services/authService';

function LoginPage() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const user = await login(username, password);
      if (user) {
        localStorage.setItem('user', JSON.stringify(user)); // Сохраняем пользователя в localStorage
        navigate('/'); // Переход на главную страницу
      }
    } catch (err) {
      setError('Неверное имя пользователя или пароль');
    }
  };

  return (
    <div style={styles.container}>
      <h2>Вход в систему</h2>
      {error && <p style={styles.error}>{error}</p>}
      <form onSubmit={handleSubmit} style={styles.form}>
        <div>
          <label>Имя пользователя:</label>
          <input
            type="text"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            required
          />
        </div>
        <div>
          <label>Пароль:</label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </div>
        <button type="submit">Войти</button>
      </form>
    </div>
  );
}

const styles = {
  container: {
    padding: '20px',
    maxWidth: '400px',
    width: '100%',
    margin: '10px auto',
    textAlign: 'center',
    boxSizing: 'border-box',
    position: 'relative',
  },

  form: {
    display: 'flex',
    flexDirection: 'column',
    gap: '15px',
  },
  error: {
    color: 'red',
  },
};

export default LoginPage;
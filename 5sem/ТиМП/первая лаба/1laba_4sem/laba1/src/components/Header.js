import React from 'react';
import { Link, useNavigate } from 'react-router-dom';

function Header() {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem('user');
    navigate('/login');
  };

  return (
    <header style={styles.header}>
      <div style={styles.logo}>Мониторинг безопасности энергетики</div>
      <nav style={styles.nav}>
        <Link to="/" style={styles.link}>Главная</Link>
        <Link to="/add" style={styles.link}>Добавить инцидент</Link>
        <Link to="/statistics" style={styles.link}>Статистика</Link>
        <button onClick={handleLogout} style={styles.logoutButton}>
          Выйти
        </button>
      </nav>
    </header>
  );
}

const styles = {
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#007bff',
    color: '#fff',
    padding: '10px 20px',
  },
  logo: {
    fontSize: '24px',
    fontWeight: 'bold',
  },
  nav: {
    display: 'flex',
    gap: '15px',
    alignItems: 'center',
  },
  link: {
    color: '#fff',
    textDecoration: 'none',
    fontSize: '16px',
  },
  logoutButton: {
    background: '#dc3545',
    color: '#fff',
    border: 'none',
    padding: '8px 12px',
    borderRadius: '5px',
    cursor: 'pointer',
  },
};

export default Header;
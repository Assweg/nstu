import React from 'react';
import { Link } from 'react-router-dom';

function Sidebar() {
  return (
    <aside style={styles.sidebar}>
      <nav>
        <ul>
          <li>
            <Link to="/">Главная</Link>
          </li>
          <li>
            <Link to="/add">Добавить инцидент</Link>
          </li>
          <li>
            <Link to="/statistics">Статистика</Link>
          </li>
        </ul>
      </nav>
    </aside>
  );
}

const styles = {
  sidebar: {
    width: '200px',
    backgroundColor: '#f4f4f9',
    padding: '20px',
    borderRight: '1px solid #ccc',
    height: '100vh',
    position: 'fixed',
    left: 0,
    top: 0,
  },
  ul: {
    listStyle: 'none',
    padding: 0,
  },
  li: {
    marginBottom: '15px',
  },
};

export default Sidebar;
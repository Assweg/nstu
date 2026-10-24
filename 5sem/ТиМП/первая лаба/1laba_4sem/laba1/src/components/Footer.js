import React from 'react';

function Footer() {
  return (
    <footer style={styles.footer}>
      <p></p>
    </footer>
  );
}

const styles = {
  footer: {
    backgroundColor: '#007bff',
    color: '#fff',
    padding: '10px',
    textAlign: 'center',
    position: 'fixed',
    bottom: 0,
    width: '100%',
  },
};

export default Footer;
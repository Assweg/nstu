function Spinner({ src }) {
  const spinStyle = {
    width: '600px',
    height: '600px',
    borderRadius: '50%',
    animation: 'spin 1.2s linear infinite',
    objectFit: 'cover',
    boxShadow: '0 0 8px rgba(0,0,0,0.2)',
  };

  if (!document.getElementById('spin-animation')) {
    const style = document.createElement('style');
    style.id = 'spin-animation';
    style.textContent = `
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
    `;
    document.head.appendChild(style);
  }

  return (
    <div style={{ textAlign: 'center', padding: '20px' }}>
      <img
        src={src}
        alt="Загрузка..."
        style={spinStyle}
      />
      <p style={{ marginTop: '10px', fontSize: '14px' }}>Загрузка...</p>
    </div>
  );
}

export default Spinner;
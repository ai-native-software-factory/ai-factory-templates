import React from 'react';
import { createRoot } from 'react-dom/client';

const App: React.FC = () => {
  return (
    <div style={{ padding: '20px', fontFamily: 'sans-serif' }}>
      <h2>AI Factory - Figma Plugin</h2>
      <button onClick={() => parent.postMessage({ type: 'create-shapes' }, '*')}>
        Create Shape
      </button>
    </div>
  );
};

const container = document.getElementById('root');
if (container) {
  const root = createRoot(container);
  root.render(<App />);
}

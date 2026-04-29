import express from 'express';

const app = express();
const port = process.env.PORT || 3000;

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.get('/', (_req, res) => {
  res.json({ message: 'AI Factory - Node Express Template' });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

export default app;

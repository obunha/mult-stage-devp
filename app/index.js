const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`Hello from the app! Environment: ${process.env.NODE_ENV || 'not set'}`);
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', timestamp: new Date().toISOString() });
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});

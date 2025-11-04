const http = require('http');

const PORT = process.env.PORT || 8080;
const MESSAGE = process.env.APP_MESSAGE || 'Hola Mundo desde AKS 👋';

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain; charset=utf-8'});
  res.end(`${MESSAGE}\n`);
});

server.listen(PORT, () => {
  console.log(`Servidor escuchando en puerto ${PORT}`);
});

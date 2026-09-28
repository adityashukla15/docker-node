const http = require('node:http');

const port = Number(process.env.PORT) || 9000;
const message = 'Hello i am docker node';

const server = http.createServer((request, response) => {
  response.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
  response.end(message);
});

server.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
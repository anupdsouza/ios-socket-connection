const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const app = express();
const server = http.createServer(app);
const io = socketIO(server);
const PORT = 3000;

server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});


// User connections
io.on('connection', (socket) => {
  console.log(`=> A User connected`);
  socket.emit('userConnected', socket.id);

  // User disconnections
  socket.on('disconnect', () => {
    console.log(`=> A User disconnected`);
    socket.emit('userDisconnected', socket.id);
  });
});
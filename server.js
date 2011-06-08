var Snake, autoClient, checkCollisions, server, snakes, sys, tick, updateState, util, websocket;
sys = require('sys');
util = require('util');
websocket = require('websocket-server');
server = websocket.createServer();
Array.prototype.remove = function(e) {
  var t, _ref;
  if ((t = this.indexOf(e)) > -1) {
    return ([].splice.apply(this, [t, t - t + 1].concat(_ref = [])), _ref);
  }
};
autoClient = 1;
snakes = [];
/* Snake Class */
Snake = (function() {
  function Snake(id) {
    this.id = id;
    this.reset();
  }
  Snake.prototype.reset = function() {
    var rH;
    rH = Math.floor(Math.random() * 49);
    this.direction = "right";
    return this.elements = [[-8, rH], [-7, rH], [-6, rH], [-5, rH], [-4, rH], [-3, rH], [-2, rH], [-1, rH]];
  };
  Snake.prototype.doStep = function() {
    var i;
    for (i = 0; i <= 6; i++) {
      this.moveTail(i);
    }
    return this.moveHead(7);
  };
  Snake.prototype.moveTail = function(i) {
    this.elements[i][0] = this.elements[i + 1][0];
    return this.elements[i][1] = this.elements[i + 1][1];
  };
  Snake.prototype.moveHead = function(i) {
    switch (this.direction) {
      case "left":
        this.elements[i][0] -= 1;
        break;
      case "right":
        this.elements[i][0] += 1;
        break;
      case "up":
        this.elements[i][1] -= 1;
        break;
      case "down":
        this.elements[i][1] += 1;
    }
    if (this.elements[i][0] < 0) {
      this.elements[i][0] = 49;
    }
    if (this.elements[i][1] < 0) {
      this.elements[i][1] = 49;
    }
    if (this.elements[i][0] > 49) {
      this.elements[i][0] = 0;
    }
    if (this.elements[i][1] > 49) {
      return this.elements[i][1] = 0;
    }
  };
  Snake.prototype.head = function() {
    return this.elements[7];
  };
  Snake.prototype.blocks = function(other) {
    var collision, element, head, _i, _len, _ref;
    head = other.elements[7];
    collision = false;
    _ref = this.elements;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      element = _ref[_i];
      if (head[0] === element[0] && head[1] === element[1]) {
        collision = true;
      }
    }
    return collision;
  };
  Snake.prototype.blocksSelf = function() {
    var collision, head, i;
    head = this.elements[7];
    collision = false;
    for (i = 0; i <= 6; i++) {
      if (head[0] === this.elements[i][0] && head[1] === this.elements[i][1]) {
        collision = true;
      }
    }
    return collision;
  };
  return Snake;
})();
/* Handle Connections */
server.addListener("connection", function(connection) {
  var clientId, clientSnake;
  clientId = autoClient;
  clientSnake = new Snake(clientId);
  autoClient += 1;
  snakes.push(clientSnake);
  sys.puts("Client " + clientId + " connected");
  connection.send(JSON.stringify({
    type: 'id',
    value: clientId
  }));
  connection.addListener("message", function(message) {
    message = JSON.parse(message);
    return clientSnake.direction = message.direction;
  });
  return connection.addListener("close", function(message) {
    snakes.remove(clientSnake);
    return sys.puts("Client " + clientId + " disconnected");
  });
});
/* Update Game State */
updateState = function() {
  var snake, _i, _len;
  for (_i = 0, _len = snakes.length; _i < _len; _i++) {
    snake = snakes[_i];
    snake.doStep();
  }
  checkCollisions();
  return server.broadcast(JSON.stringify({
    type: 'snakes',
    value: snakes
  }));
};
checkCollisions = function() {
  var other, resetSnakes, snake, _i, _j, _k, _len, _len2, _len3, _results;
  resetSnakes = [];
  for (_i = 0, _len = snakes.length; _i < _len; _i++) {
    snake = snakes[_i];
    if (snake.blocksSelf()) {
      resetSnakes.push(snake);
    }
    for (_j = 0, _len2 = snakes.length; _j < _len2; _j++) {
      other = snakes[_j];
      if (other !== snake) {
        if (other.blocks(snake)) {
          resetSnakes.push(snake);
        }
      }
    }
  }
  _results = [];
  for (_k = 0, _len3 = resetSnakes.length; _k < _len3; _k++) {
    snake = resetSnakes[_k];
    _results.push(snake.reset());
  }
  return _results;
};
tick = setInterval(updateState, 100);
/* Start Server */
server.listen(8000);
sys.puts("Server started");
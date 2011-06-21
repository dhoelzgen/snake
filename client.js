(function() {
  if (window["WebSocket"]) {
    $(document).ready(function() {
      var animate, canvas, connect, context, id, sendDirection, server;
      server = null;
      canvas = $("#stage");
      context = canvas.get(0).getContext("2d");
      id = null;
      sendDirection = function(direction) {
        if (server) {
          return server.send(JSON.stringify({
            'direction': direction
          }));
        }
      };
      animate = function(snakes) {
        var element, snake, x, y, _i, _len, _results;
        context.fillStyle = 'rgb(230,230,230)';
        for (x = 0; x <= 49; x++) {
          for (y = 0; y <= 49; y++) {
            context.fillRect(x * 10, y * 10, 9, 9);
          }
        }
        _results = [];
        for (_i = 0, _len = snakes.length; _i < _len; _i++) {
          snake = snakes[_i];
          context.fillStyle = snake.id === id ? 'rgb(170,0,0)' : 'rgb(0,0,0)';
          if (snake.id === id) {
            $("#kills").html("Kills: " + snake.kills);
            $("#deaths").html("Deaths: " + snake.deaths);
          }
          _results.push((function() {
            var _j, _len2, _ref, _results2;
            _ref = snake.elements;
            _results2 = [];
            for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
              element = _ref[_j];
              x = element[0] * 10;
              y = element[1] * 10;
              _results2.push(context.fillRect(x, y, 9, 9));
            }
            return _results2;
          })());
        }
        return _results;
      };
      connect = function() {
        server = new io.Socket("localhost", {
          'port': 5000
        });
        server.connect();
        return server.on("message", function(event) {
          var message;
          message = JSON.parse(event);
          switch (message.type) {
            case 'id':
              return id = message.value;
            case 'snakes':
              return animate(message.value);
          }
        });
      };
      connect();
      return $(document).keydown(function(event) {
        var key;
        key = event.keyCode ? event.keyCode : event.which;
        switch (key) {
          case 37:
            return sendDirection("left");
          case 38:
            return sendDirection("up");
          case 39:
            return sendDirection("right");
          case 40:
            return sendDirection("down");
        }
      });
    });
  } else {
    alert("Your browser does not support websockets.");
  }
}).call(this);

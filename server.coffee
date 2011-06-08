sys = require 'sys'
util = require 'util'
websocket = require 'websocket-server'
server = websocket.createServer()

autoClient = 1
snakes = []

### Snake Class ###

class Snake
	constructor: (@id) ->
		@direction = "right"	
		@elements = [[-8, 200], [-7, 200], [-6, 200], [-5, 200], [-4, 200], [-3, 200], [-2, 200], [-1, 200]]
	
	doStep: ->
		@moveTail i for i in [0..6]
		@moveHead 7
	
	moveTail: (i) ->
		@elements[i][0] = @elements[i+1][0]
		@elements[i][1] = @elements[i+1][1]
			
	moveHead: (i) ->
		switch @direction
			when "left" then @elements[i][0] -= 1
			when "right" then @elements[i][0] += 1
			when "up" then @elements[i][1] -= 1
			when "down" then @elements[i][1] += 1
		sys.puts(util.inspect @elements, @direction)
		

### Handle Connections ###

server.addListener "connection", (connection) ->
	clientId = autoClient
	clientSnake = new Snake clientId
	
	autoClient += 1
	snakes.push clientSnake

	sys.puts "Client #{clientId} connected"
	
	connection.addListener "message", (message) ->
		message = JSON.parse(message)
		sys.puts("Client #{clientId}: " + message.direction)
		clientSnake.direction = message.direction

server.addListener "close", (connection) ->
	sys.puts("Client disconnected")

### Update Game State ###

updateState = ->
	sys.puts "Doing step for #{snakes.length} snakes"
	snake.doStep() for snake in snakes
	# server.broadcast JSON.stringify({'server': 'test'})

tick = setInterval updateState, 5000

### Start Server ###	

server.listen(8000)
sys.puts "Server started"
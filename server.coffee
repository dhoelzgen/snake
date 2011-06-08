sys = require 'sys'
util = require 'util'
websocket = require 'websocket-server'

server = websocket.createServer()

HOST = null
PORT = 5000

STAGE_WIDTH = 49
STAGE_HEIGHT = 49
SNAKE_LENGTH = 8

Array::remove = (e) -> @[t..t] = [] if (t = @.indexOf(e)) > -1

autoClient = 1
snakes = []

### Snake Class ###

class Snake
	constructor: (@id) ->
		@reset()
	
	reset: ->
		rH = Math.floor(Math.random()*49)
		@direction = "right"	
		@elements = ([-i, rH] for i in [SNAKE_LENGTH..1])
	doStep: ->
		@moveTail i for i in [0..(SNAKE_LENGTH-2)]
		@moveHead()
	
	moveTail: (i) ->
		@elements[i][0] = @elements[i+1][0]
		@elements[i][1] = @elements[i+1][1]
			
	moveHead: ->
		head = SNAKE_LENGTH - 1
		
		switch @direction
			when "left" then @elements[head][0] -= 1
			when "right" then @elements[head][0] += 1
			when "up" then @elements[head][1] -= 1
			when "down" then @elements[head][1] += 1
			
		@elements[head][0] = STAGE_WIDTH if @elements[head][0] < 0
		@elements[head][1] = STAGE_HEIGHT if @elements[head][1] < 0
		@elements[head][0] = 0 if @elements[head][0] > STAGE_WIDTH
		@elements[head][1] = 0 if @elements[head][1] > STAGE_HEIGHT
		
	head: ->
		@elements[SNAKE_LENGTH-1]
		
	blocks: (other) ->
		head = other.elements[(SNAKE_LENGTH-1)]
		collision = false
		for element in @elements
			collision = true if head[0] == element[0] and head[1] == element[1]

		return collision
		
	blocksSelf: ->
		head = @elements[(SNAKE_LENGTH-1)]
		collision = false
		for i in [0..(SNAKE_LENGTH-2)]
			collision = true if head[0] == @elements[i][0] and head[1] == @elements[i][1]
		
		return collision

### Handle Connections ###

server.addListener "connection", (connection) ->
	clientId = autoClient
	clientSnake = new Snake clientId
	
	autoClient += 1
	snakes.push clientSnake

	sys.puts "Client #{clientId} connected"
	connection.send JSON.stringify(
		type: 'id',
		value: clientId
	)
	
	connection.addListener "message", (message) ->
		message = JSON.parse(message)
		clientSnake.direction = message.direction
		
	connection.addListener "close", (message) ->
		snakes.remove clientSnake
		sys.puts("Client #{clientId} disconnected")

### Update Game State ###

updateState = ->
	snake.doStep() for snake in snakes
	checkCollisions()
	server.broadcast JSON.stringify(
		type: 'snakes',
		value: snakes
	)
	
checkCollisions = ->
	resetSnakes = []
	
	for snake in snakes
		resetSnakes.push snake if snake.blocksSelf()
		
		for other in snakes
			if other isnt snake
				resetSnakes.push snake if other.blocks snake
		
	for snake in resetSnakes
		snake.reset()

tick = setInterval updateState, 100

### Start Server ###	

server.listen(port = Number(process.env.PORT || PORT), HOST)
sys.puts "Server running on port #{port}"
sys = require 'sys'
http = require 'http'
util = require 'util'
url = require 'url'
io = require 'socket.io'
fs = require 'fs'

HOST = null
PORT = 5000

STAGE_WIDTH = 49
STAGE_HEIGHT = 49
SNAKE_LENGTH = 8

Array::remove = (e) -> @[t..t] = [] if (t = @.indexOf(e)) > -1

autoClient = 1
snakes = []

### Server ###

server = http.createServer (req, res) ->
	path = url.parse(req.url).pathname
	switch path
		when '/', '/index.html', '/client.js', '/style.css'
			path = '/index.html' if path == '/'
			fs.readFile __dirname + path, (err, data) ->
				if err
					send404(res)
				else
			 		res.writeHead 200, 'text/html'
					res.write data, 'utf8'
					res.end()
					
		else send404 res

send404 = (res) ->
  res.writeHead 404
  res.write '404'
  res.end()
		
server.listen port = Number(process.env.PORT || PORT)

### Snake Class ###

class Snake
	constructor: (@id) ->
		@reset()
		@kills = 0
		@deaths = 0
		
	addKill: ->
	  @kills++
	  @length = @elements.unshift([-1,-1])
	
	reset: ->
		rH = Math.floor(Math.random()*49)
		@deaths++
		@length = SNAKE_LENGTH
		@direction = "right"	
		@elements = ([-i, rH] for i in [@length..1])
		
	doStep: ->
		@moveTail i for i in [0..(@length-2)]
		@moveHead()
	
	moveTail: (i) ->
		@elements[i][0] = @elements[i+1][0]
		@elements[i][1] = @elements[i+1][1]
			
	moveHead: ->
		head = @length - 1
		
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
		@elements[@length-1]
		
	blocks: (other) ->
		head = other.head()
		collision = false
		for element in @elements
			collision = true if head[0] == element[0] and head[1] == element[1]

		return collision
		
	blocksSelf: ->
		head = @head()
		collision = false
		for i in [0..(@length-2)]
			collision = true if head[0] == @elements[i][0] and head[1] == @elements[i][1]
		
		return collision

### Handle Connections ###

socket = io.listen(server)
socket.on "connection", (client) ->
	clientId = autoClient
	clientSnake = new Snake clientId
	
	autoClient += 1
	snakes.push clientSnake

	sys.puts "Client #{clientId} connected"
	client.send JSON.stringify(
		type: 'id',
		value: clientId
	)
	
	client.on "message", (message) ->
		message = JSON.parse(message)
		clientSnake.direction = message.direction
		
	client.on "disconnect", ->
		snakes.remove clientSnake
		sys.puts("Client #{clientId} disconnected")

### Update Game State ###

updateState = ->
	snake.doStep() for snake in snakes
	checkCollisions()
	socket.broadcast JSON.stringify(
		type: 'snakes',
		value: snakes
	)
	
checkCollisions = ->
	resetSnakes = []
	
	for snake in snakes
		resetSnakes.push snake if snake.blocksSelf()
		
		for other in snakes
			if other isnt snake
				if other.blocks snake
				  resetSnakes.push snake 
				  other.addKill()
		
	for snake in resetSnakes
		snake.reset()

tick = setInterval updateState, 100

### Start Server ###	

sys.puts "Server running on port #{port}"
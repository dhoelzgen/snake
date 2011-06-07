sys = require 'sys'
websocket = require 'websocket-server'
server = websocket.createServer()

autoClient = 1
snakes = []

### Snake Class ###

class Snake
	constructor: (@id) ->
		@elements = [[-8, 200], [-7, 200], [-6, 200], [-5, 200], [-4, 200], [-3, 200], [-2, 200], [-1, 200]]
		@direction = "right"
		
	doStep: ->
		moveElement i for i in [0..7]
		
	moveElement: (i) ->
		switch @direction
			when "left" then @elements[i][0] -= 1
			when "right" then @elements[i][1] += 1
			when "up" then @elements[i][0] -= 1
			when "down" then @elements[i][0] += 1

### Handle Connections ###

server.addListener "connection", (connection) ->
	clientId = autoClient
	autoClient += 1
	
	snakes.push new Snake clientId
	
	connection.addListener "message", (message) ->
		sys.puts("Client #{clientId} says: " + message)

server.addListener "close", (connection) ->
	sys.puts("Client disconnected")

### Update Game State ###

updateState = ->
	server.broadcast JSON.stringify({'server': 'test'})

# tick = setInterval updateState, 5000

### Start Server ###	

server.listen(8000)
sys.puts "Server started"
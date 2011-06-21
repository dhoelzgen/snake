if window["WebSocket"]
	
	$(document).ready ->
		server = null
		canvas = $("#stage")
		context = canvas.get(0).getContext("2d")
		
		id = null

		sendDirection = (direction) ->
			server.send(JSON.stringify({'direction': direction})) if server
		
		animate = (snakes) ->
			# Clear stage
			context.fillStyle = 'rgb(230,230,230)'
			for x in [0..49]
				for y in [0..49]
					context.fillRect(x*10,y*10,9,9)
			
			# Draw snakes
			for snake in snakes
				context.fillStyle = if snake.id == id then 'rgb(170,0,0)' else 'rgb(0,0,0)'
				
				if snake.id == id
				  $("#kills").html("Kills: #{snake.kills}")
				  $("#deaths").html("Deaths: #{snake.deaths}")
				
				for element in snake.elements
					x = element[0] * 10
					y = element[1] * 10
					context.fillRect(x, y, 9, 9)
			
		connect = ->
			server = new io.Socket("localhost", { 'port': 5000 })
			server.connect()
			server.on "message", (event) ->
				message = JSON.parse(event)
				switch message.type
					when 'id' then id = message.value
					when 'snakes' then animate message.value
		
		connect()
		
		$(document).keydown (event) ->
	 		key = if event.keyCode then event.keyCode else event.which
	 		switch key
	 			when 37 then sendDirection "left"
	 			when 38 then sendDirection "up"
	 			when 39 then sendDirection "right"
	 			when 40 then sendDirection "down"
						
else
	alert "Your browser does not support websockets."


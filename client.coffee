if window["WebSocket"]
	
	server = null
	
	sendDirection = (direction) ->
		server.send(JSON.stringify({'direction': direction})) if server
	
	$(document).ready ->
		canvas = $("#stage")
		context = canvas.get(0).getContext("2d")
	
		connect = ->
			server = new WebSocket("ws://localhost:8000")
			server.onmessage = (message) ->
				alert message
		
		connect()
		
		$(document).keydown (event) ->
			
				key = if event.keyCode then event.keyCode else event.which
				switch key
					when 37 then sendDirection "left"
					when 38 then sendDirection "up"
					when 39 then sendDirection "right"
					when 40 then sendDirection "down"
				
			
		
else
	### Implement error message of use flash fallback ###


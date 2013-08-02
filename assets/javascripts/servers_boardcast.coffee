$('#boardcast').submit ->
	if @password.value and @content.value
		$.getJSON 'http://my-card.in/servers.json', (data)=>
			$('#result').empty()
			data.push {index: 'http://122.0.65.70:7986/'}
			for server in data
				$('<li/>').append($('<iframe />', src: "#{server.index}?operation=boardcast&pass=#{@password.value}&content=#{@content.value}", class: "result", scrolling: 'no')).appendTo('#result')
			$(@content).val('')
	false
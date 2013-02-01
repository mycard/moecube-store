$.getJSON '/servers.json', (data)->
  for server in data
    $('<tr />').append(
      $('<td />', text: String.fromCharCode 'A'.charCodeAt() + server.id),
      $('<td />', text: server.name),
      $('<td />').append($('<a />', 'href': server.index, 'text': server.index)),
      $('<td />', text: server.ip),
      $('<td />', text: server.port),
      $('<td />', text: server.auth),
      $('<td />', text: server.pvp)
    ).appendTo($('#servers'))
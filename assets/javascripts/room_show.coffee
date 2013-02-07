matched = window.location.href.match /\/(?:(.*?)(?::(.*?))?@)?([\d\.]+)\:(\d+)(?:\/(.*))?/
if matched == null
  alert "解析房间信息失败"
  throw window.location.href
url = $.url 'mycard:/' + matched[0]

#room = url.attr('file').split('$')
room = _.string.ltrim(url.attr('path'), '/').split('$')

room = {
  name: room[0]
  password: room[1]
  private: url.param('private')
  server: {
    ip: url.attr('host')
    port: url.attr('port')
    auth: url.param('server_auth')
  }
}

$('#name').html room.name
if room.password
  $('#show_password').html room.password
  $('#show_password_wrapper').show()
else if room.private
  $('#input_password').change ->
    room.password = @value
  $('#input_password_wrapper').show()

$('#server_ip').html room.server.ip
$('#server_port').html room.server.port
$('#server_auth').html room.server.auth

$('#join').click ->
  mycard.join room.server.ip,room.server.port,mycard.room_name(room.name, room.password)
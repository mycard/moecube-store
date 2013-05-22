login = (username, password)->
  $('#username').html username
  $('#login').hide()
  $('#userinfo').show()
  $('#need_login').hide()
  $('#join').show()

$('#logout').click ->
  $.cookie('username', '')
  $.cookie('password', '')
  window.location.reload()
$('#login').submit ->
  $.cookie('username', @username.value)
  $.cookie('password', @password.value)
  login($.cookie('username'), $.cookie('password'))
  false

matched = window.location.href.match /\/(?:(.*?)(?::(.*?))?@)?([\d\.]+)\:(\d+)(?:\/(.*))?/
if matched == null
  alert "解析房间信息失败"
  throw window.location.href
url = $.url 'mycard:/' + matched[0]

#room = url.attr('file').split('$')
room = _.string.ltrim(url.attr('path'), '/').split('$')

room = {
  name: decodeURIComponent room[0]
  password: decodeURIComponent room[1] if room[1]
  _private: url.param('private')
  server: {
    ip: url.attr('host')
    port: url.attr('port')
    auth: !!url.param('server_auth')
  }
}

$('#name').html room.name
if room.password
  $('#show_password').html room.password
  $('#show_password_wrapper').show()
else if room._private
  $('#input_password').change ->
    room.password = @value
  $('#input_password_wrapper').show()

$('#server_ip').html room.server.ip
$('#server_port').html room.server.port
$('#server_auth').html room.server.auth.toString()

if room.server.auth and !($.cookie('username') && $.cookie('password'))
  $('#join').hide()
  $('#need_login').show()

if $.cookie('username') && $.cookie('password')
  login($.cookie('username'), $.cookie('password'))

$('#join').click ->
  mycard.join room.server.ip,room.server.port,mycard.room_name(room.name, room.password), $.cookie('username'), ($.cookie('password') if room.server.auth)

if location.hash == '#share'
  $('#room_url').val mycard.room_url room.server.ip,room.server.port,mycard.room_name(room.name, room.password), null, null, room._private, room.server.auth
  $('#share').modal(backdrop: 'static')
  $('#room_url').focus()
  $('#room_url').select()
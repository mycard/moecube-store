@mycard = {}
@mycard.room_name = (name, password, pvp = false, rule = 0, mode = 0, start_lp = 8000, start_hand = 5, draw_count = 1) ->
  if rule != 0 or start_lp != 8000 or start_hand != 5 or draw_count != 1
    result = "#{rule}#{mode}FFF#{start_lp},#{start_hand},#{draw_count},"
  else if mode == 2
    result = "T#"
  else if pvp and mode == 1
    result = "PM#"
  else if pvp
    result = "P#"
  else if mode == 1
    result = "M#"
  else
    result = ""
  result += name
  result = encodeURIComponent(result)
  if password
    result += '$' + encodeURIComponent(password)
  result

#127.0.0.1:8087/test
@mycard.room_string = (ip,port,room,username,password, _private, server_auth)->
  result = ''
  if username
    result += encodeURIComponent(username)
    if password
      result += ':' + encodeURIComponent(password)
    result += '@'
  result += ip + ':' + port + '/' + room
  if _private
    result += '?private=true'
    if server_auth
      result += '&server_auth=true'
  else if server_auth
    result += '?server_auth=true'
  result

#http://my-card.in/rooms/127.0.0.1:8087/test
@mycard.room_url = (ip,port,room,username,password, _private, server_auth)->
  result = 'http://my-card.in/rooms/' + @room_string(ip,port,room,username,password, _private, server_auth)

#mycard://127.0.0.1:8087/test
@mycard.room_url_mycard = (ip,port,room,username,password, _private, server_auth)->
  result = 'mycard://' + @room_string(ip,port,room,username,password, _private, server_auth)

@mycard.join = (ip,port,room,username,password, _private, server_auth)->
  window.location.href = @room_url_mycard(ip,port,room,username,password, _private, server_auth)
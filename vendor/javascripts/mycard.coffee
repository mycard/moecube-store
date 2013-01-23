@mycard = {}
@mycard.room_name = (name, password, pvp = false, rule = 0, mode = 0, start_lp = 8000) ->
  if rule != 0 or start_lp != 8000
    result = "#{rule}#{mode}FFF#{start_lp},5,1,"
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
  if password
    result += '$' + password
  result

@mycard.join = (ip,port,room,username,password)->
  result = 'mycard://'
  if username
    result += encodeURIComponent(username)
    if password
      result += ':' + encodeURIComponent(password)
    result += '@'
  result += ip + ':' + port + '/' + encodeURIComponent(room)
  window.location.href = result
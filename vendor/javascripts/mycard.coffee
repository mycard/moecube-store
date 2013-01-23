@mycard = {}
@mycard.join = (ip,port,room,username,password)->
  result = 'mycard://'
  if username
    result += encodeURIComponent(username)
    if password
      result += ':' + encodeURIComponent(password)
    result += '@'
  result += ip + ':' + port + '/' + encodeURIComponent(room)
  window.location.href = result
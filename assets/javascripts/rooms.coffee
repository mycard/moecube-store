class Server extends Spine.Model
  @configure "Server", "name", "ip", "port", "index"
  @extend Spine.Model.Ajax
  @url: "/servers.json"

class Room extends Spine.Model
  @configure "Room", "name", "status", "private"
  @belongsTo 'server', Server
class Rooms extends Spine.Controller

  events:
    'click .room': 'clicked'
  constructor: ->
    super
    Room.bind "refresh", @render
  render: =>
    @html $('#room_template').tmpl _.sortBy Room.all(), @sort
  sort: (room)->
    [
      if room.status == "wait" then 0 else 1,
      room.private
    ]
  clicked: (e)->
    room = $(e.target).tmplItem().data
    if room.private
      $('#join_private_room')[0].reset()
      $('#join_private_room').data('room_id', room.id)
      $('#join_private_room_dialog').dialog('open')
    else
      mycard.join(room.server().ip, room.server().port, room.name)


$(document).ready ->
  if true #for debug
    Candy.init('/http-bind/',
      core:
        debug: false,
        autojoin: ['mycard@conference.my-card.in'],
      view:
        resources: '/vendor/stylesheets/candy/',
        language: 'cn'
    )
    Candy.Core.connect('zh99998测试80@my-card.in', 'zh112998') if window.location.href.indexOf("candy") != -1
    $('#candy').show()
  #$('#username').val '@my-card.in'
  #$('#username').focus()

  $('#new_room_dialog').dialog
    autoOpen:false,
    resizable:false,
    title:"建立房间"

  $('#join_private_room_dialog').dialog
    autoOpen:false,
    resizable:false,
    title:"加入私密房间"

  new_room = $('#new_room')[0]
  new_room.tag.onchange = ->
    if @checked
      new_room.pvp.checked = false
      new_room.match.checked = false
  new_room.match.onchange = ->
    if @checked
      new_room.tag.checked = false
  new_room.pvp.onchange = ->
    if @checked
      new_room.tag.checked = false
      new_room.tcg.checked = false
      new_room.ocg.checked = true
      new_room.lp.value = 8000
  new_room.ocg.onchange = ->
    if !@checked
      new_room.tcg.checked = true
  new_room.tcg.onchange = ->
    if @checked
      new_room.pvp.checked = false
    else
      new_room.ocg.checked = true

  new_room.onsubmit = (ev)->
    ev.preventDefault()
    $('#new_room_dialog').dialog('close')

    rule = if @tcg.checked then (if @ocg.checked then 2 else 1) else 0
    mode = if @tag.checked then 2 else if @match.checked then 1 else 0
    if rule != 0 or @lp.value != '8000'
      result = "#{rule}#{mode}FFF#{@lp.value},5,1,"
    else if @tag.checked
      result = "T#"
    else if @pvp.checked and @match.checked
      result = "PM#"
    else if @pvp.checked
      result = "P#"
    else if @match.checked
      result = "M#"
    result += @name.value
    if @password.value
      result += '$' + @password.value

    servers = Server.all()
    server = servers[Math.floor Math.random() * servers.length]
    mycard.join(server.ip, server.port, result)



  $('#join_private_room').submit (ev)->
    ev.preventDefault()
    $('#join_private_room_dialog').dialog('close')

    if @password.value
      room_id = $(this).data('room_id')
      if Room.exists room_id
        room = Room.find(room_id)
        server = room.server()
        mycard.join(server.ip, server.port, "#{room.name}$#{@password.value}")
      else
        alert '房间已经关闭'

  $('#new_room_button').click ->
    new_room.reset()
    new_room.name.value = Math.floor Math.random() * 1000
    $('#new_room_dialog').dialog('open')


  rooms = new Rooms(el: $('#rooms'))

  Server.one "refresh", ->
    wsServer = 'ws://mycard-server.my-card.in:9998'
    websocket = new WebSocket(wsServer);
    websocket.onopen = ->
      console.log("Connected to WebSocket server.")
    websocket.onclose = ->
      console.log("Disconnected");
    websocket.onmessage = (evt)->
      console.log('Retrieved data from server: ' + evt.data)
      rooms = JSON.parse(evt.data)
      for room in rooms
        if room._deleted
          Room.find(room.id).destroy() if Room.exists(room.id)
      Room.refresh (room for room in rooms when !room._deleted)

    websocket.onerror = (evt)->
      console.log('Error occured: ' + evt.data);
  Server.fetch()



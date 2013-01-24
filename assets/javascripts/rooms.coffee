class Server extends Spine.Model
  @configure "Server", "name", "ip", "port", "index"
  @extend Spine.Model.Ajax
  @url: "/servers.json"

class Room extends Spine.Model
  @configure "Room", "name", "status", "private", "rule", "mode", "start_lp"
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
      alert room
      mycard.join(room.server().ip, room.server().port, mycard.room_name(room.name, null, room.pvp, room.rule, room.mode, room.start_lp))

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
    Candy.View.Template.Chat.infoMessage = ''
    Candy.Core.connect('zh99998测试80@my-card.in', 'zh112998') if window.location.href.indexOf("candy") != -1
    #window.onunload = window.onbeforeunload
    window.onbeforeunload = null

    $('#candy').show()
  #$('#username').val '@my-card.in'
  #$('#username').focus()
  #stroll.bind( '.online_list ul' );

  $('#new_room_dialog').dialog
    autoOpen:false,
    resizable:false,
    title:"建立房间"

  $('#join_private_room_dialog').dialog
    autoOpen:false,
    resizable:false,
    title:"加入私密房间"

  new_room = $('#new_room')[0]
  new_room.pvp.onchange = ->
    if @checked
      new_room.mode.value = 1 if new_room.mode.value == '2'
      new_room.rule.value = 0
      new_room.start_lp.value = 8000
  new_room.mode.onchange = ->
    if @value == '2'
      new_room.pvp.checked = false
  new_room.rule.onchange = ->
    if @value != '0'
      new_room.pvp.checked = false
  new_room.start_lp.onchange = ->
    if @value != '8000'
      new_room.pvp.checked = false
  new_room.onsubmit = (ev)->
    ev.preventDefault()
    $('#new_room_dialog').dialog('close')

    servers = Server.all()
    server = servers[Math.floor Math.random() * servers.length]
    mycard.join server.ip, server.port, mycard.room_name(@name.value, @password.value, @pvp.checked, parseInt(@rule.value), parseInt(@mode.value), parseInt(@start_lp.value))

  $('#join_private_room').submit (ev)->
    ev.preventDefault()
    $('#join_private_room_dialog').dialog('close')

    if @password.value
      room_id = $(this).data('room_id')
      if Room.exists room_id
        room = Room.find(room_id)
        mycard.join(room.server().ip, room.server().port, mycard.room_name(room.name, @password.value, room.pvp, room.rule, room.mode, room.start_lp))
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



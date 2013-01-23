class Server extends Spine.Model
  @configure "Server", "name", "ip", "port", "index"
  @extend Spine.Model.Ajax
  @url: "/servers.json"

class Room extends Spine.Model
  @configure "Room",
    "name",
    "status"

class Rooms extends Spine.Controller
  constructor: ->
    super
    Room.bind "refresh", @render
  render: =>
    @html $('#room_template').tmpl _.sortBy Room.all(), @sort
  sort: (room)->
    [if room.status == "wait" then 0 else 1]



$(document).ready ->
  Candy.init('/http-bind/',
    core:
      debug: false,
      autojoin: ['mycard@conference.my-card.in'],
    view:
      resources: '/vendor/stylesheets/candy/',
      language: 'cn'
  )
  Candy.Core.connect('zh99998测试80@my-card.in', 'zh112998')
  #$('#username').val '@my-card.in'
  #$('#username').focus()
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

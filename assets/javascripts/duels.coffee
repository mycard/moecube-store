upload = (files, callback) ->
  file = files[0]
  return unless file
  reader = new FileReader()
  $('#upload').attr 'disabled', true
  reader.onload = (ev)->
    $('#upload').attr 'disabled', false
    window.location = url file.name.split('.')[0], base64.encode(ev.target.result).replace /[+\/=]/g, (m)->
      switch m
        when '+' then '-'
        when '/' then '_'
        when '=' then ''

  reader.readAsBinaryString(file)

url = (name, replay, format='', scheme='http')->
  "#{scheme}://my-card.in/duels/new#{format}?name=#{encodeURIComponent(name)}&replay=#{replay}"

$(document).ready ->
  if $.url().param('replay')
    template = Handlebars.compile $('#duel-template').html()
    name = $.url().param('name')
    replay = $.url().param('replay')
    $('#duel').html template(name: name, url_yrp: url(name, replay, '.yrp'), url_mycard: url(name, replay, '.yrp', 'mycard') + "&name=#{encodeURIComponent(name)}.yrp")

  $('#upload').change ->
    upload @files
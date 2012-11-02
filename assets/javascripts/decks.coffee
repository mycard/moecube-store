locale = 'zh'
class Card extends Spine.Model
  @type = [
    'Warrior',
    'Spellcaster',
    'Fairy',
    'Fiend',
    'Zombie',
    'Machine',
    'Aqua',
    'Pyro',
    'Rock',
    'Winged_Beast',
    'Plant',
    'Insect',
    'Thunder',
    'Dragon',
    'Beast',
    'Beast-Warrior',
    'Dinosaur',
    'Fish',
    'Sea_Serpent',
    'Reptile',
    'Psychic',
    'Divine-Beast',
    'Creator_God'
  ]
  @configure "Card", "atk", "name"
  @extend Spine.Model.Ajax
  @extend Spine.Events
  @url: "https://api.mongolab.com/api/1/databases/mycard/collections/cards?apiKey=508e5726e4b0c54ca4492ead"
  @locale_url: "https://api.mongolab.com/api/1/databases/mycard/collections/lang_#{locale}?apiKey=508e5726e4b0c54ca4492ead"
  @query: (q, callback)->
    $.getJSON "#{@url}&q=#{JSON.stringify(q)}", (cards) =>
      cards_id = (card._id for card in cards)
      $.getJSON "#{@locale_url}&q=#{JSON.stringify({_id: { $in: cards_id}})}", (langs) =>
        cards = (for lang in langs
          id = lang.id = lang._id
          for card in cards
            if card._id == id
              $.extend(lang, card)
              break
          lang
        )
        @refresh cards
        callback(cards)

class CardUsage extends Spine.Model
  @configure "CardUsage", "card_id", "count", "side"
  @belongsTo 'card', Card

class Deck extends Spine.Controller
  events: "mouseenter .card": "show"

  constructor: ->
    super
    CardUsage.bind("refresh change", @render)
  render: =>
    @html $("#card_template").tmpl(CardUsage.all())
  show: (e) ->
    card = $(e.target).tmplItem().data.card()
    $("#card_image").attr 'src', "https://raw.github.com/zh99998/ygopro-images/master/#{card.id}.jpg"
    $("#card_name").html card.name
decode = (str)->
	key = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789*-="
	result = 0
	for char in str
		result <<= 6
		result += key.indexOf(char)
	result

name = $.url().param('name')
cards_encoded = $.url().param('cards')
$('img#qrcode').attr('src', 'https://chart.googleapis.com/chart?chs=200x200&cht=qr&chld=|0&chl=' + encodeURIComponent("http://my-card.in/decks/inline?name=#{name}&cards=#{cards_encoded}"))
$('#name').html(name)

$(document).ready ->
  deck = []
  cards_id = []
  for i in [0...cards_encoded.length] by 5
    decoded = decode(cards_encoded.substr(i, 5))
    side = decoded >> 29
    count = decoded >> 27 & 0x3
    id = decoded & 0x07FFFFFF
    cards_id.push id
    deck.push {card_id: id, count: count, side: side}

  a = new Deck(el: $("#deck"))
  Card.query {_id: { $in: cards_id}}, =>
    CardUsage.refresh deck
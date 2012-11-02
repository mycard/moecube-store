locale = 'zh'
class Card extends Spine.Model
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
  constructor: ->
    super
    CardUsage.bind("refresh change", @render)
  render: =>
    @html $("#card_template").tmpl(CardUsage.all())

decode = (str)->
	key = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789*-="
	result = 0
	for char in str
		result <<= 6
		result += key.indexOf(char)
	result

$('img#qrcode').attr('src', 'https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl=' + encodeURIComponent(location.href))
$('#name').html($.url().param('name'))
cards_encoded = $.url().param('cards')

deck = []
cards_id = []
for i in [0...cards_encoded.length] by 5
  decoded = decode(cards_encoded.substr(i, 5))
  side = decoded >> 29
  count = decoded >> 27 & 0x3
  id = decoded & 0x07FFFFFF
  cards_id.push id
  deck.push {card_id: id, count: count, side: side}
  $('#cards').append($('<dt />', {text: id}))
  $('#cards').append($('<dd />', {text: count}))
a = new Deck(el: $("#deck"))
Card.query {_id: { $in: cards_id}}, =>
  CardUsage.refresh deck
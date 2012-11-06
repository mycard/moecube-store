locale = 'zh'
class Card extends Spine.Model
  @types = ['Warrior', 'Spellcaster', 'Fairy', 'Fiend', 'Zombie', 'Machine', 'Aqua', 'Pyro', 'Rock', 'Winged_Beast', 'Plant', 'Insect', 'Thunder', 'Dragon', 'Beast', 'Beast-Warrior', 'Dinosaur', 'Fish', 'Sea_Serpent', 'Reptile', 'Psychic', 'Divine-Beast', 'Creator_God']
  @_attributes = ['EARTH', 'WATER', 'FIRE', 'WIND', 'LIGHT', 'DARK', 'DIVINE']
  @card_types = ['Monster', 'Spell', 'Trap', null, 'Normal', 'Effect', 'Fusion', 'Ritual', null, 'Spirit', 'Union', 'Gemini', 'Tuner', 'Synchro', null, null, 'Quick-Play', 'Continuous', 'Equip', 'Field', 'Counter', 'Flip', 'Toon', 'Xyz']
  @categories = ['Monster', 'Spell', 'Trap']
  @card_types_extra = ['Fusion', 'Synchro', 'Xyz']
  @configure 'Card', 'id', 'name', 'card_type', 'type', 'attribute', 'level', 'atk', 'def', 'description'
  @extend Spine.Model.Ajax
  @extend Spine.Events
  @hasMany 'card_usages', CardUsage
  @url: "https://api.mongolab.com/api/1/databases/mycard/collections/cards?apiKey=508e5726e4b0c54ca4492ead"
  @locale_url: "https://api.mongolab.com/api/1/databases/mycard/collections/lang_#{locale}?apiKey=508e5726e4b0c54ca4492ead"
  image_url: ->
    "http://images.my-card.in/#{@id}.jpg"
  image_thumbnail_url: ->
    "http://images.my-card.in/thumbnail/#{@id}.jpg"
  @query: (q, callback)->
    $.getJSON "#{@url}&q=#{JSON.stringify(q)}", (cards) =>
      cards_id = (card._id for card in cards)
      $.getJSON "#{@locale_url}&q=#{JSON.stringify({_id:{ $in: cards_id}})}", (langs) =>
        cards = (for lang in langs
          for card in cards
            if card._id == lang._id
              $.extend(lang, card)
              break

          card_type = []
          i=0
          while lang.type
            if lang.type & 1
              card_type.push @card_types[i]
            lang.type >>= 1
            i++

          {
          id: card._id
          alias: card.alias
          name: lang.name
          card_type: card_type
          type: (i = 0; (i++ until lang.race >> i & 1); @types[i]) if lang.race
          attribute: (i = 0; (i++ until lang.attribute >> i & 1); @_attributes[i]) if lang.attribute
          level: card.level
          atk: card.atk
          def: card.def
          description: lang.desc
          }
        )
        @refresh cards
        callback(cards)

class CardUsage extends Spine.Model
  @configure 'CardUsage', 'card_id', 'count', 'side'
  @belongsTo 'card', Card

class Deck extends Spine.Controller
  deck_name: ""
  events:
    'mouseover .card_usage': 'show',
    'click .card_usage': 'add',
    'contextmenu .card_usage': 'minus'

  key: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789*-="
  constructor: ->
    super
    CardUsage.bind("refresh change", @render)
  encode: ->
    result = ''
    for card_usage in @main.concat @extra, @side
      c = card_usage.side << 29 | card_usage.count << 27 | card_usage.card_id
      for i in [4..0]
        result += @key.charAt((c >> i * 6) & 0x3F)
    result
  decode: (str)->
    card_usages = for i in [0...str.length] by 5
      decoded = 0
      for char in str.substr(i, 5)
        decoded = (decoded << 6) + @key.indexOf(char)
      card_id = decoded & 0x07FFFFFF
      side = decoded >> 29
      count = decoded >> 27 & 0x3
      {card_id: card_id, side: side, count: count}
    Card.query {_id: { $in: card_usage.card_id for card_usage in card_usages}}, =>
      CardUsage.refresh card_usages, clear: true

  render: =>
    @main = []
    @side = []
    @extra = []
    main_count = 0
    side_count = 0
    extra_count = 0
    category_count = {}
    for category in Card.categories
      category_count[category] = 0
    CardUsage.each (card_usage)=>
      card = card_usage.card()
      if card_usage.side
        @side.push card_usage
        side_count += card_usage.count
      else if (card_type for card_type in card.card_type when card_type in Card.card_types_extra).length
        @extra.push card_usage
        extra_count += card_usage.count
      else
        @main.push card_usage
        main_count += card_usage.count
        category_count[(category for category in card.card_type when category in Card.categories).pop()] += card_usage.count
    @html $('#deck_template').tmpl({main: @main, side: @side, extra: @extra, main_count: main_count, side_count: side_count, extra_count: extra_count, category_count: category_count})
    $('.card_usage').draggable()
    if $('.operate_area').hasClass('text')
      @el.jscroll({W: "12px", Btn:
        {btn: false}});


    @url = "http://my-card.in/decks/?name=#{@deck_name}&cards=#{@encode()}"

  #alert @url
  #$('#deck_url_ydk').attr 'download', Deck.deck_name + '.ydk'
  #$('#deck_url_ydk').attr 'href', 'data:application/octet-stream,' +  (card_usage.card_id for i in  ).concat((card_usage.card_id for i in [0...card_usage.count] for card_usage in @extra), ["!side"], (card_usage.card_id for i in [0...card_usage.count] for card_usage in @side)).join("%0a")
  tab_control: ->
    $(".bottom_area div").click ->
      $(this).addClass("bottom_button_active").removeClass("bottom_button")
      $(this).siblings().addClass("bottom_button").removeClass("bottom_button_active")
      $dangqian = $(".card_frame .frame_element").eq($(".bottom_area div").index(this));
      $dangqian.addClass("card_frame_focus");
      $dangqian.siblings().removeClass("card_frame_focus");
    $('.card_frame .frame_element').jscroll({W: "12px", Btn:
      {btn: false}});
  show: (e) ->
    card = $(e.target).tmplItem().data.card()
    $('#card').removeClass(Card.card_types.join(' '))
    active_page_index = $('.bottom_area div').index $(".bottom_button_active")
    $('#card').html $("#card_template").tmpl(card)
    $('#card').addClass(card.card_type.join(' '))
    $('.card_frame .frame_element').eq(active_page_index).addClass('card_frame_focus')
    $('.bottom_area div').eq(active_page_index).addClass('bottom_button_active').removeClass("bottom_button")
    @tab_control()
  add: (e)->
    card_usage = $(e.target).tmplItem().data
    count = 0
    for c in CardUsage.findAllByAttribute('card_id', card_usage.card_id)  #TODO: alias
      count += c.count
    if count < 3 #TODO: lflist
      card_usage.count++
      card_usage.save()
    history.pushState(null, @deck_name, @url)
  minus: (e)->
    e.preventDefault()
    card_usage = $(e.target).tmplItem().data
    card_usage.count--
    if card_usage.count
      card_usage.save()
    else
      card_usage.destroy()
    history.pushState(null, @deck_name, @url)


$(document).ready ->
  $('#name').html $.url().param('name')
  $("#deck_share_dialog").dialog
    modal: true
    autoOpen: false

  $('#deck_share').click ->
    $("#deck_url").val
    $("#deck_share_dialog").dialog('open')

  #$.ajax({url: 'https://www.googleapis.com/urlshortener/v1/url', type: 'POST', data:JSON.stringify({longUrl: 'http://my-card.in/'}), contentType: 'application/json; charset=utf-8', success: function(data){alert(data)} })"
  $.i18n.properties
    name: 'card'
    path: '/locales/'
    mode: 'map'
    cache: true
    callback: ->
      deck = new Deck(el: $("#deck"))
      deck.deck_name = $.url().param('name')
      deck.tab_control()
      deck.decode $.url().param('cards')
#window.addEventListener 'popstate', (ev)->
#  alert ev.state
#if ev.state
#  CardUsage.refresh ev.state, clear: true
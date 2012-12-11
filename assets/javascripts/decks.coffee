locale = 'zh'
class Card extends Spine.Model
  @types = ['Warrior', 'Spellcaster', 'Fairy', 'Fiend', 'Zombie', 'Machine', 'Aqua', 'Pyro', 'Rock', 'Winged_Beast', 'Plant', 'Insect', 'Thunder', 'Dragon', 'Beast', 'Beast-Warrior', 'Dinosaur', 'Fish', 'Sea_Serpent', 'Reptile', 'Psychic', 'Divine-Beast', 'Creator_God']
  @_attributes = ['EARTH', 'WATER', 'FIRE', 'WIND', 'LIGHT', 'DARK', 'DIVINE']
  @card_types = ['Monster', 'Spell', 'Trap', null, 'Normal', 'Effect', 'Fusion', 'Ritual', null, 'Spirit', 'Union', 'Gemini', 'Tuner', 'Synchro', null, null, 'Quick-Play', 'Continuous', 'Equip', 'Field', 'Counter', 'Flip', 'Toon', 'Xyz']
  @categories = ['Monster', 'Spell', 'Trap']
  @card_types_extra = ['Fusion', 'Synchro', 'Xyz']
  @configure 'Card', 'id', 'name', 'card_type', 'type', 'attribute', 'level', 'atk', 'def', 'description'
  @extend Spine.Model.Local
  @extend Spine.Events
  @hasMany 'card_usages', CardUsage
  @url: "https://api.mongolab.com/api/1/databases/mycard/collections/cards?apiKey=508e5726e4b0c54ca4492ead"
  @locale_url: "https://api.mongolab.com/api/1/databases/mycard/collections/lang_#{locale}?apiKey=508e5726e4b0c54ca4492ead"
  image_url: ->
    "http://my-card.in/images/cards/ygocore/#{@id}.jpg"
  image_thumbnail_url: ->
    "http://my-card.in/images/cards/ygocore/thumbnail/#{@id}.jpg"
  @fetch_by_name: (name, callback)->
    $.getJSON "#{@locale_url}&q=#{JSON.stringify {name: {$regex: name.replace(/([.?*+^$[\]\\(){}|-])/g, '\\$1'), $options: 'i'}}}", (langs) =>
      alert langs
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
    @refresh card_usages
  refresh: (card_usages)->
    cards_need_load = (card_usage.card_id for card_usage in card_usages when !Card.exists(card_usage.card_id))
    if cards_need_load.length
      Card.query {_id: { $in: cards_need_load}}, =>
        CardUsage.refresh card_usages, clear: true
    else
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

    if $('.operate_area').hasClass('graphic')
      window.main_count = if main_count > 40 then main_count else 'auto'
      window.side_count = if side_count > 10 then side_count else 'auto'
      window.extra_count = if extra_count > 10 then extra_count else 'auto'

    @html $('#deck_template').tmpl({main: @main, side: @side, extra: @extra, main_count: main_count, side_count: side_count, extra_count: extra_count, category_count: category_count})
    $('#search_card').html $('#search_card_template').tmpl({test: 'test'})

    $('#deck_url_ydk').attr 'download', @deck_name + '.ydk'
    $('#deck_url_ydk').attr 'href', 'data:application/octet-stream,' + ((card_usage.card_id for i in [0...card_usage.count]).join("%0a") for card_usage in @main).concat(((card_usage.card_id for i in [0...card_usage.count]).join("%0a") for card_usage in @extra), ["!side"], ((card_usage.card_id for i in [0...card_usage.count]).join("%0a") for card_usage in @side)).join("%0a")
    #$('#deck_url_ydk').attr 'href', 'data:application/octet-stream;headers=' + encodeURIComponent('Content-Disposition: attachment; filename=' + @deck_name + '.ydk') + ',' + (card_usage.card_id for i in [0...card_usage.count] for card_usage in @main).concat((card_usage.card_id for i in [0...card_usage.count] for card_usage in @extra), ["!side"], (card_usage.card_id for i in [0...card_usage.count] for card_usage in @side)).join("%0a")
    $( ".deck_part" ).sortable(
      connectWith: ".deck_part"
      stop: =>
        card_usages = []
        last_item = null
        for el in $('.card_usage')
          card_id = $(el).tmplItem().data.card_id
          side = $(el).parent().hasClass('side')

          if last_item
            if last_item.card_id == card_id and last_item.side == side
              last_item.count++
            else
              card_usages.push last_item
              last_item = {card_id: card_id, side: side, count: 1}
          else
            last_item = {card_id: card_id, side: side, count: 1}
        card_usages.push last_item
        @refresh card_usages
        @set_history()
    ).disableSelection();
    if $('.operate_area').hasClass('text')
      #文字版
      @el.jscroll({W: "12px", Btn:
        {btn: false}})
    else
      main_margin = Math.floor(($('.deck_part').width() - $('.card_usage').width() * Math.max(((main_count-1) / 4)+1,10)) / (Math.max(((main_count-1) / 4)+1,10)-1) / 2)
      $('.deck_part.main').css {'margin-left': -main_margin, 'margin-right': -main_margin}
      $('.deck_part.main .card_usage').css {'margin-left': main_margin, 'margin-right': main_margin}

      side_margin = Math.floor(($('.deck_part').width() - $('.card_usage').width() * Math.max(side_count,10)) / (Math.max(side_count,10)-1) / 2)
      $('.deck_part.side').css {'margin-left': -side_margin, 'margin-right': -side_margin}
      $('.deck_part.side .card_usage').css {'margin-left': side_margin, 'margin-right': side_margin}

      extra_margin = Math.floor(($('.deck_part').width() - $('.card_usage').width() * Math.max(extra_count,10)) / (Math.max(extra_count,10)-1) / 2)
      $('.deck_part.extra').css {'margin-left': -extra_margin, 'margin-right': -extra_margin}
      $('.deck_part.extra .card_usage').css {'margin-left': extra_margin, 'margin-right': extra_margin}
  location: ->
    "/decks/?name=#{@deck_name}&cards=#{@encode()}"
  url: ->
    "http://my-card.in" + @location()
  set_history: ->
    history.pushState(CardUsage.toJSON(), @deck_name, @location())

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
    @set_history()
  minus: (e)->
    e.preventDefault()
    card_usage = $(e.target).tmplItem().data
    card_usage.count--
    if card_usage.count
      card_usage.save()
    else
      card_usage.destroy()
    @set_history()

$(document).ready ->
  $('#name').html $.url().param('name')
  $("#deck_share_dialog").dialog
    modal: true
    autoOpen: false

  deck = new Deck(el: $("#deck"))
  deck.deck_name = $.url().param('name')
  deck.tab_control()

  $('#deck_share').click ->
    $("#deck_url").val deck.url()
    $("#deck_url_qrcode").attr 'src', 'https://chart.googleapis.com/chart?chs=200x200&cht=qr&chld=|0&chl=' + encodeURIComponent(deck.url())
    $("#deck_share_dialog").dialog('open')
  $('#deck_url_shorten').click ->
    $('#deck_url_shorten').attr "disabled",true
    $.ajax
      url: 'https://www.googleapis.com/urlshortener/v1/url'
      type: 'POST'
      data: JSON.stringify {longUrl: deck.url()}
      contentType: 'application/json; charset=utf-8'
      success: (data)->
        $("#deck_url").val data.id
        $('#deck_url_shorten').attr "disabled", false
  $('#deck_load').change ->
    file = @files[0]
    reader = new FileReader()
    $('#deck_load').attr 'disabled', true
    $('#name').html deck.deck_name = file.name.split('.')[0]
    reader.onload = (ev)->
      result = []
      lines = ev.target.result.split("\n")
      side = false
      last_id = 0
      count = 0
      for line in lines
        if line.charAt(0) == '#'
          continue
        else if line.substr(0,5) == '!side'
          result.push {card_id: last_id, side: side, count: count} if last_id
          side = true
        else
          card_id = parseInt(line)
          if card_id
            if card_id == last_id
              count++
            else
              result.push {card_id: last_id, side: side, count: count} if last_id
              last_id = card_id
              count = 1
      result.push {card_id: last_id, side: side, count: count} if last_id
      $('#deck_load').attr 'disabled', false
      deck.refresh result
      deck.set_history()
    reader.readAsText(file)

  $.i18n.properties
    name: 'card'
    path: '/locales/'
    mode: 'map'
    cache: true
    callback: ->
      Card.fetch ->
        $('#search').submit ->
          Card.fetch_by_name $('.search_input').val()
          return false

        deck.decode $.url().param('cards')
        window.addEventListener 'popstate', (ev)->
          if ev.state
            deck.refresh ev.state, false
      Card.fetch()
      $(".rename_ope").click ->
        $(".text,.graphic").toggleClass("graphic text")
        deck.render()

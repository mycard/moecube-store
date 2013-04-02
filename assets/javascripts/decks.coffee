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
  @url: "http://my-card.in/cards"
  @locale_url: "http://my-card.in/cards_#{locale}"
  image_url: ->
    "http://my-card.in/images/cards/ygocore/#{@id}.jpg"
  image_thumbnail_url: ->
    "http://my-card.in/images/cards/ygocore/thumbnail/#{@id}.jpg"

  @load: (cards, langs)->
    @refresh(for lang in langs
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


  @fetch_by_name: (name, callback)->
    $.getJSON "#{@locale_url}?q=#{JSON.stringify {name: {$regex: name.replace(/([.?*+^$[\]\\(){}|-])/g, '\\$1'), $options: 'i'}}}", (langs) =>
      result = []
      cards_id = []
      for lang in langs
        try
          result.push Card.find(lang._id)
        catch e
          cards_id.push lang._id
      if cards_id.length
        $.getJSON "#{@url}?q=#{JSON.stringify({_id: { $in: cards_id}})}", (cards) =>
          @load cards, langs
          for card in cards
            result.push Card.find(card._id)
          callback(result)
      else
        callback(result)

  @fetch_by_id: (cards_id, callback, before, after)->
    cards_id = (card_id for card_id in cards_id when !Card.exists(card_id))
    if cards_id.length
      before() if before
      $.when($.getJSON("#{@url}?q=#{JSON.stringify({_id:
        {$in: cards_id}})}"), $.getJSON("#{@locale_url}?q=#{JSON.stringify({_id: { $in: cards_id}})}")).done (cards, langs)=>
          @load(cards[0], langs[0])
          callback()
          after() if after
    else
      callback()


class CardUsage extends Spine.Model
  @configure 'CardUsage', 'count', 'side'
  @belongsTo 'card', Card
  @belongsTo 'deck', Deck

class Deck extends Spine.Model
  @configure 'Deck', 'name'
  @hasMany 'card_usages', CardUsage

  @key: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_="
  encode: ->
    result = ''
    for card_usage in @card_usages().all()
      c = card_usage.side << 29 | card_usage.count << 27 | card_usage.card_id
      for i in [4..0]
        result += Deck.key.charAt((c >> i * 6) & 0x3F)
    result
  sort: ->
    @_main = []
    @_side = []
    @_extra = []
    @_main_count = 0
    @_side_count = 0
    @_extra_count = 0
    @_category_count = {}
    for category in Card.categories
      @_category_count[category] = 0
    for card_usage in @card_usages().all()
      card = card_usage.card()
      if card_usage.side
        @_side.push card_usage
        @_side_count += card_usage.count
      else if (card_type for card_type in card.card_type when card_type in Card.card_types_extra).length
        @_extra.push card_usage
        @_extra_count += card_usage.count
      else
        @_main.push card_usage
        @_main_count += card_usage.count
        @_category_count[(category for category in card.card_type when category in Card.categories).pop()] += card_usage.count
  main: ->
    @sort() if !@_main?
    @_main
  side: ->
    @sort() if !@_side?
    @_side
  extra: ->
    @sort() if !@_extra?
    @_extra
  main_count: ->
    @sort() if !@_main_count?
    @_main_count
  side_count: ->
    @sort() if !@_side_count
    @_side_count
  extra_count: ->
    @sort() if !@_extra_count
    @_extra_count
  category_count: ->
    @sort() if !@_category_count?
    @_category_count
  @decode: (str, name)->
    result = new Deck(name: name)
    result.save()
    card_usages = []
    for i in [0...str.length] by 5
      decoded = 0
      for char in str.substr(i, 5)
        decoded = (decoded << 6) + @key.indexOf(char)
      side = decoded >> 29
      count = decoded >> 27 & 0x3
      card_id = decoded & 0x07FFFFFF
      card_usages.push {id: "#{result.cid}_#{side}_#{card_id}", card_id: card_id, side: side, count: count}
    result.card_usages card_usages
    result
  @load: (str, name)->
    result = new Deck(name: name)
    result.save()
    card_usages = []
    lines = str.split("\n")
    side = false
    last_id = 0
    count = 0
    for line in lines
      if !line or line.charAt(0) == '#'
        continue
      else if line.substr(0, 5) == '!side'
        card_usages.push {card_id: last_id, side: side, count: count} if last_id
        side = true
        last_id = null
      else
        card_id = parseInt(line)
        if card_id
          if card_id == last_id
            count++
          else
            card_usages.push {id: "#{result.cid}_#{side}_#{last_id}", card_id: last_id, side: side, count: count} if last_id
            last_id = card_id
            count = 1
        else
          throw '无效卡组'
    card_usages.push {id: "#{result.cid}_#{side}_#{last_id}", card_id: last_id, side: side, count: count} if last_id
    result.card_usages card_usages
    result

  location: ->
    "/decks/new?name=#{@name}&cards=#{@encode()}"
  location_ydk: ->
    "/decks/new.ydk?name=#{@name}&cards=#{@encode()}"
  url: ->
    "http://my-card.in" + @location()
  url_ydk: ->
    "http://my-card.in" + @location_ydk()
  url_mycard: ->
    "mycard://my-card.in" + @location_ydk() + "&filename=#{@name}.ydk"

  add: (card_usage)->
    if !card_usage.card_id #card
      card_usage = @card_usages().findByAttribute('card_id', card.id) || new CardUsage(card_id: card_usage.id, deck_id: @id, main: true, count: 0)
    count = 0
    for c in @card_usages().findAllByAttribute('card_id', card_usage.card_id)  #TODO: alias
      count += c.count
    if count < 3 #TODO: lflist
      card_usage.count++
      card_usage.save()
  minus: (card_usage)->
    if !card_usage.card_id #card
      card_usage = @card_usages().findByAttribute('card_id', card_usage.id)
    return if !card_usage
    card_usage.count--
    if card_usage.count
      card_usage.save()
    else
      card_usage.destroy()
class DecksController extends Spine.Controller
  events:
    'mouseover .card_usage': 'show',
    'click .card_usage': 'add',
    'contextmenu .card_usage': 'minus'

  deck: (deck) ->
    if deck
      @_deck = deck
      CardUsage.bind('change refresh', @refresh)
      @refresh()
      $('#name').html deck.name
    @_deck

  refresh: =>
    Card.fetch_by_id((card_usage.card_id for card_usage in @deck().card_usages().all()), =>
        @deck().sort()
        @render()
      , =>
        @html $('#loading_template').tmpl()
    )
  render: =>
    @html $('#deck_template').tmpl({main: @deck().main(), side: @deck().side(), extra: @deck().extra(), main_count: @deck().main_count(), side_count: @deck().side_count(), extra_count: @deck().extra_count(), category_count: @deck().category_count()})
    @set_history()
    @set_download()

    ###
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
        @deck().card_usages card_usages, clear: true
    ).disableSelection();
    ###

    if $('.operate_area').hasClass('text')
      #文字版
      @el.jscroll({W: "12px", Btn:
        {btn: false}})
    else
      deck_width = $('.deck_part').width()
      card_width = $('.card_usage').width()

      main_margin = Math.floor((deck_width - card_width * Math.max(Math.ceil(@deck().main_count() / 4), 10)) / (Math.max(Math.ceil(@deck().main_count() / 4), 10) - 1) / 2)
      $('.deck_part.main').css {'margin-left': -main_margin, 'margin-right': -main_margin}
      $('.deck_part.main .card_usage').css {'margin-left': main_margin, 'margin-right': main_margin}

      side_margin = Math.floor((deck_width - card_width * Math.max(@deck().side_count(), 10)) / (Math.max(@deck().side_count(), 10) - 1) / 2)
      $('.deck_part.side').css {'margin-left': -side_margin, 'padding-right': -side_margin}
      $('.deck_part.side .card_usage').css {'margin-left': side_margin, 'margin-right': side_margin}

      extra_margin = Math.floor((deck_width - card_width * Math.max(@deck().extra_count(), 10)) / (Math.max(@deck().extra_count(), 10) - 1) / 2)
      $('.deck_part.extra').css {'margin-left': -extra_margin, 'padding-right': -extra_margin}
      $('.deck_part.extra .card_usage').css {'margin-left': extra_margin, 'margin-right': extra_margin}

  upload: (files)->
    file = files[0]
    reader = new FileReader()
    $('#deck_load').attr 'disabled', true if file
    reader.onload = (ev)->
      $('#deck_load').attr 'disabled', false
      try
        decks.deck Deck.load(ev.target.result, file.name.split('.')[0])
      catch error
        alert error

    reader.readAsText(file)

  load_from_url: (url)->
    try
      decks.deck Deck.decode $.url(url).param('cards'), $.url().param('name')
    catch error
      alert error

  set_history: ->
    history.pushState(CardUsage.toJSON(), @deck().name, @deck().location()) unless @deck().location() == $.url().attr('relative')
  set_download: ->
    if $.browser.chrome
      $('#deck_url_ydk').attr 'download', @deck().name + '.ydk'
      $('#deck_url_ydk').attr 'href', 'data:application/x-ygopro-deck,' + encodeURI ["#generated by mycard/web"].concat(
        (card_usage.card_id for i in [0...card_usage.count]).join("\r\n") for card_usage in @deck().main(),
        (card_usage.card_id for i in [0...card_usage.count]).join("\r\n") for card_usage in @deck().extra(),
        ["!side"],
        (card_usage.card_id for i in [0...card_usage.count]).join("\r\n") for card_usage in @deck().side()
      ).join("\r\n")
    else
      $('#deck_url_ydk').attr 'href', @deck().url_ydk()
    $('#deck_url_mycard').attr 'href', @deck().url_mycard()
  tab_control: ->
    $(".bottom_area div").click ->
      $(this).addClass("bottom_button_active").removeClass("bottom_button")
      $(this).siblings().addClass("bottom_button").removeClass("bottom_button_active")
      $dangqian = $(".card_frame .frame_element").eq($(".bottom_area div").index(this))
      ;
      $dangqian.addClass("card_frame_focus")
      ;
      $dangqian.siblings().removeClass("card_frame_focus")
      ;
    $('.card_frame .frame_element').jscroll({W: "12px", Btn:
      {btn: false}})
    ;
  show: (e) ->
    card = $(e.target).tmplItem().data
    card = card.card() if card.card_id
    $('#card').removeClass(Card.card_types.join(' '))
    active_page_index = $('.bottom_area div').index $(".bottom_button_active")
    $('#card').html $("#card_template").tmpl(card)
    $('#card').addClass(card.card_type.join(' '))
    $('.card_frame .frame_element').eq(active_page_index).addClass('card_frame_focus')
    $('.bottom_area div').eq(active_page_index).addClass('bottom_button_active').removeClass("bottom_button")
    @tab_control()
  add: (e)->
    @deck().add $(e.target).tmplItem().data
  minus: (e)->
    e.preventDefault()
    @deck().minus $(e.target).tmplItem().data

class CardsController extends Spine.Controller
  events:
    'mouseover .search_card': 'show',
    'click .search_card': 'add',
    'contextmenu .search_card': 'minus'
  add: (e)->
    decks.deck().add($(e.target).tmplItem().data)
  minus: (e)->
    e.preventDefault()
    decks.deck().minus($(e.target).tmplItem().data)
  show: (e)->
    decks.show(e)
  template: ->
    $('#search_cards_' + (if $('.operate_area').hasClass('text') then 'text' else 'graphic') + '_template')
  search: (name)->
    Card.fetch_by_name name, (cards)=>
      category_count = {}
      for category in Card.categories
        category_count[category] = 0
      for card in cards
        category_count[(category for category in card.card_type when category in Card.categories).pop()]++
      $("#search_cards_spells_count").html category_count.Spell
      $("#search_cards_traps_count").html category_count.Trap
      $("#search_cards_monsters_count").html category_count.Monster
      @html @template().tmpl cards
      @el.easyPaginate(step: 7, delay: 30)


decks = new DecksController(el: $("#deck"))
cards = new CardsController(el: $("#search_cards"))

#there is a bug in old version deck editor.
competition_convert = {'*':'-', '-':'_'}
if document.location.href.indexOf('*') >= 0
  location.href = document.location.href.replace /[\*\-]/g, (char)-> competition_convert[char]

$(document).ready ->
  decks.load_from_url()

  $('#search').submit ->
    cards.search $('.search_input').val()
    return false

  #dialog
  $("#deck_share_dialog").dialog
    modal: true
    autoOpen: $.url().attr('fragment') == 'share'
    width: 600
    open: ->
      $("#deck_url").val decks.deck().url()
      $("#deck_url")[0].select()
      $("#deck_url_qrcode").attr 'src', 'https://chart.googleapis.com/chart?chs=171x171&cht=qr&chld=|0&chl=' + encodeURIComponent(decks.deck().url())

  $("#drop_upload_dialog").dialog
    dialogClass: 'drop_upload'
    draggable: false
    resizable: false
    modal: true
    autoOpen: false

  #share
  $('#deck_share').click ->
    $("#deck_share_dialog").dialog('open')

  $('#deck_url_shorten').click ->
    $('#deck_url_shorten').attr "disabled", true
    $.ajax
      url: 'https://www.googleapis.com/urlshortener/v1/url'
      type: 'POST'
      data: JSON.stringify {longUrl: decks.deck().url()}
      contentType: 'application/json; charset=utf-8'
      success: (data)->
        $("#deck_url").val data.id
        $("#deck_url")[0].select()
        $('#deck_url_shorten').attr "disabled", false

  #upload
  $('#deck_load').change ->
    decks.upload(@files)

  $(window).bind 'popstate', (ev)->
    if ev.state
      deck.refresh ev.state, false

  $('.main_div').bind 'dragover', (ev)->
    ev.preventDefault();
    #$("#drop_upload_dialog").dialog('open')

  $('.main_div').bind 'drop', (ev)->
    ev.preventDefault();
    $("#drop_upload_dialog").dialog('close')
    decks.upload event.dataTransfer.files

  $(".switch").click ->
    $(".text,.graphic").toggleClass("graphic text")
    decks.render()


  $.i18n.properties
    name: 'card'
    path: '/locales/'
    mode: 'map'
    cache: true

  addthis.init()
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
    $.getJSON "#{@locale_url}&q=#{JSON.stringify {name: {$regex: name.replace(/([.?*+^$[\]\\(){}|-])/g, '\\$1'), $options: 'i'}}}", (langs) =>
      result = []
      cards_id = []
      for lang in langs
        try
          result.push Card.find lang._id
        catch e
          cards_id.push lang._id
      if cards_id.length
        $.getJSON "#{@url}&q=#{JSON.stringify({_id:{ $in: cards_id}})}", (cards) =>
          @load cards, langs
          for card in cards
            result.push Card.find card._id
          callback(result)
      else
        callback(result)

  @fetch_by_id: (cards_id, callback)->
    cards_id = (card_id for card_id in cards_id when !Card.exists(card_id))
    if cards_id.length
      $.when($.getJSON("#{@url}&q=#{JSON.stringify({_id: {$in: cards_id}})}"), $.getJSON("#{@locale_url}&q=#{JSON.stringify({_id:{ $in: cards_id}})}")).done (cards, langs)=>
        @load(cards[0], langs[0])
        callback()
    else
      callback()


class CardUsage extends Spine.Model
  @configure 'CardUsage', 'count', 'side'
  @belongsTo 'card', Card
  @belongsTo 'deck', Deck

class Deck extends Spine.Model
  @configure 'Deck', 'name'
  @hasMany 'card_usages', CardUsage

  @key: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789*-="
  encode: ->
    result = ''
    for card_usage in @main.concat @extra, @side
      c = card_usage.side << 29 | card_usage.count << 27 | card_usage.card_id
      for i in [4..0]
        result += @key.charAt((c >> i * 6) & 0x3F)
    result
  @decode: (str, name)->
    card_usages = []
    result = new Deck(name: name)
    result.save()
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

class CardsController extends Spine.Controller
  events:
    'mouseover .card_search_result': 'show',
    'click .card_search_result': 'add',
    'contextmenu .card_search_result': 'minus'
  add: (e)->
    Deck.current.add_card($(this).tmplItem().data)
  minus: (e)->
    Deck.current.minus_card($(this).tmplItem().data)
  show: (e)->
    Deck.current.show_card($(this).tmplItem().data)
  search: (name)->
    Card.fetch_by_name name, (cards)=>
      @html $('#cards_search_result_template').tmpl cards


class DecksController extends Spine.Controller

  events:
    'mouseover .card_usage': 'show',
    'click .card_usage': 'add',
    'contextmenu .card_usage': 'minus'

  deck: (deck) ->
    if deck
      @_deck = deck
      @_deck.bind('change', @refresh)
      @refresh(deck)
    @_deck

  #constructor: ->
  #  super
  #  CardUsage.bind("refresh change", @refresh)

  refresh: (deck)=>
    Card.fetch_by_id (card_usage.card_id for card_usage in deck.card_usages().all()), =>
      @render()

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
    #alert @deck().card_usages()
    for card_usage in @deck().card_usages().all()
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
    $('#search_card').html $('#search_card_template').tmpl({test: 'test'})

    if $.browser.chrome
      $('#deck_url_ydk').attr 'download', @deck_name + '.ydk'
      $('#deck_url_ydk').attr 'href', 'data:application/x-ygopro-deck,' + encodeURI ["#generated by mycard/web"].concat(
        (card_usage.card_id for i in [0...card_usage.count]).join("\r\n") for card_usage in @main,
        (card_usage.card_id for i in [0...card_usage.count]).join("\r\n") for card_usage in @extra,
        ["!side"],
        (card_usage.card_id for i in [0...card_usage.count]).join("\r\n") for card_usage in @side
      ).join("\r\n")
    else
      $('#deck_url_ydk').attr 'href', @url_ydk()

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
      deck_width = $('.deck_part').width()
      card_width = $('.card_usage').width()

      main_margin = Math.floor((deck_width - card_width * Math.max(Math.ceil(main_count/4),10)) / (Math.max(Math.ceil(main_count/4),10)-1) / 2)
      $('.deck_part.main').css {'margin-left': -main_margin, 'margin-right': -main_margin}
      $('.deck_part.main .card_usage').css {'margin-left': main_margin, 'margin-right': main_margin}

      side_margin = Math.floor((deck_width - card_width * Math.max(side_count,10)) / (Math.max(side_count,10)-1) / 2)
      $('.deck_part.side').css {'margin-left': -side_margin, 'padding-right': -side_margin}
      $('.deck_part.side .card_usage').css {'margin-left': side_margin, 'margin-right': side_margin}

      extra_margin = Math.floor((deck_width - card_width * Math.max(extra_count,10)) / (Math.max(extra_count,10)-1) / 2)
      $('.deck_part.extra').css {'margin-left': -extra_margin, 'padding-right': -extra_margin}
      $('.deck_part.extra .card_usage').css {'margin-left': extra_margin, 'margin-right': extra_margin}


  location: ->
    "/decks/new?name=#{@deck_name}&cards=#{@encode()}"
  location_ydk: ->
    "/decks/new.ydk?name=#{@deck_name}&cards=#{@encode()}"
  url: ->
    "http://my-card.in" + @location()
  url_ydk: ->
    "http://my-card.in" + @location_ydk()
  set_history: ->
    history.pushState(CardUsage.toJSON(), @deck_name, @location())

  @tab_control: ->
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
    @show_card(card)
  show_card: (card)->
    $('#card').removeClass(Card.card_types.join(' '))
    active_page_index = $('.bottom_area div').index $(".bottom_button_active")
    $('#card').html $("#card_template").tmpl(card)
    $('#card').addClass(card.card_type.join(' '))
    $('.card_frame .frame_element').eq(active_page_index).addClass('card_frame_focus')
    $('.bottom_area div').eq(active_page_index).addClass('bottom_button_active').removeClass("bottom_button")
    DecksController.tab_control()
  add: (e)->
    card_usage = $(e.target).tmplItem().data
    count = 0
    for c in CardUsage.findAllByAttribute('card_id', card_usage.card_id)  #TODO: alias
      count += c.count
    if count < 3 #TODO: lflist
      card_usage.count++
      card_usage.save()
    @set_history()
  add_card: (card)->
    card_usage = CardUsage.findByAttribute('card_id', card.id) || new CardUsage(card_id: card.id, main: true, count: 0)
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
  minus_card: (card)->
    e.preventDefault()
    card_usage = CardUsage.findByAttribute('card_id', card.id)
    return unless card_usage
    card_usage.count--
    if card_usage.count
      card_usage.save()
    else
      card_usage.destroy()
    @set_history()


class CardsSearchController extends Spine.Controller


$(document).ready ->
  $('#name').html $.url().param('name')
  $("#deck_share_dialog").dialog
    modal: true
    autoOpen: false
  addthis.init()


  $.i18n.properties
    name: 'card'
    path: '/locales/'
    mode: 'map'
    cache: true
    callback: ->



      @decks = new DecksController(el: $("#deck"))
      #@decks.tab_control()
      @cards_search = new CardsSearchController(el: $("#cards_search"))

      @decks.deck Deck.decode $.url().param('cards'), $.url().param('name')

      #search
      $('#search').submit ->
        cards_search.search $('.search_input').val()
        return false

      #share
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

      #upload
      $('#deck_load').change ->
        file = @files[0]
        reader = new FileReader()
        $('#deck_load').attr 'disabled', true if file
        reader.onload = (ev)->
          $('#deck_load').attr 'disabled', false
          result = []
          lines = ev.target.result.split("\n")
          side = false
          last_id = 0
          count = 0
          for line in lines
            if !line or line.charAt(0) == '#'
              continue
            else if line.substr(0,5) == '!side'
              result.push {card_id: last_id, side: side, count: count} if last_id
              side = true
              last_id = null
            else
              card_id = parseInt(line)
              if card_id
                if card_id == last_id
                  count++
                else
                  result.push {card_id: last_id, side: side, count: count} if last_id
                  last_id = card_id
                  count = 1
              else
                alert('无效卡组')
                return
          result.push {card_id: last_id, side: side, count: count} if last_id
          $('#name').html deck.deck_name = file.name.split('.')[0]
          deck.refresh result
          deck.set_history()
        reader.readAsText(file)


      window.addEventListener 'popstate', (ev)->
        if ev.state
          deck.refresh ev.state, false

      $(".rename_ope").click ->
        $(".text,.graphic").toggleClass("graphic text")
        deck.render()

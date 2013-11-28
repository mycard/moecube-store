$(".navbar").click ->
  $('body').animate scrollTop: 0

$.getJSON 'https://my-card.in/links.json', (data)->
  for link in data
    $('<li/>').append($('<a />',
      href: link.url
      rel: "nofollow"
    ).append($('<img />',
      title: link.name
      alt: link.name
      src: "https://my-card.in/links/#{link.id}.png"
    ))).appendTo('#links')

if navigator.userAgent.toLowerCase().indexOf("android") > -1
  #android
  $('#download_android').removeClass('hidden')
else
  #desktop
  $('#download_desktop').removeClass('hidden')

$.getJSON 'https://my-card.in/duelists.json', (data)->
  $('#duelist_lastest_issue').html data[data.length-1].issue
  $('#duelist_lastest_issue').removeClass('hidden')
  $('#duelists').html (for duelist in data
    $('<li/>').append($('<a/>', href: duelist.url, text: duelist.title )))
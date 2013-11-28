$.getJSON 'https://my-card.in/links.json', (data)->
  for link in data
    $('<li/>').append($('<a />',
      href: link.url
      rel: "nofollow"
    ).append($('<img />',
      title: link.name
      alt: link.name
      src: link.logo
    ))).appendTo('#links')

if navigator.userAgent.toLowerCase().indexOf("android") > -1
  #android
  $('#download_android').removeClass('hidden')
else
  #desktop
  $('#download_desktop').removeClass('hidden')

$.getJSON 'http://www.duelist.cn/api/book/list', (data)->
  $('#duelist_lastest_issue').html data[data.length-1].issue
  $('#duelists').html (for duelist in data
    $('<li/>').append($('<a/>', href: duelist.url, text: duelist.title )))
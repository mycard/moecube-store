$(document).ready ->

  #slider
  $('#slider').cycle
    fx:'fade'
    timeout:7200
    random:1

  #version
  $.get '/mycard/download.url', (data)->
    if matched = data.match(/mycard-(.*)-win32\.7z/)
      $('#download_version').html matched[1]
    else
      $('#download_version').html '读取失败'

  #link
  $.getJSON '/links.json', (data)->
    for link in data
      $('<a />',
        href: link.url
        rel: "nofollow"
      ).append($('<img />',
        title: link.name
        alt: link.name
        src: link.logo
      )).appendTo('#links')

  #duelist
  #$.getJSON 'http://www.duelist.cn/api/book/list?callback=?', (data)->
  #  alert data

  #test
  $('body').css 'margin', '1px'
  $('body').css 'margin', 0

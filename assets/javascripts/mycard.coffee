$(document).ready ->

  #slider
  $('#slider').cycle
    fx:'fade'
    timeout:7200
    random:1

  #version
  if navigator.userAgent.toLowerCase().indexOf("android") > -1
    #android
    $('#download').css('background', 'none')
    $('#download_url, .download_information').remove()
    $('#download').prepend('<a href="https://play.google.com/store/apps/details?id=android.ygo">
      <img alt="Get it on Google Play"
           src="https://developer.android.com/images/brand/zh-cn_generic_rgb_wo_60.png" />
    </a>')
  else
    $.get '/mycard/download.url', (data)->
      if matched = data.match(/mycard-(.*?)-(.*)\.(.*)/)
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
  #$('body').css 'margin', '5px'
  #$('body').css 'margin', 0

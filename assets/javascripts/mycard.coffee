$(document).ready ->

  #slider
  $('#slider').cycle
    fx:'fade'
    timeout:7200
    random:1

  $.get '/mycard/download.url', (data)->
    if matched = data.match(/mycard-(.*)-win32\.7z/)
      $('#download_version').html matched[1]
    else
      $('#download_version').html '读取失败'
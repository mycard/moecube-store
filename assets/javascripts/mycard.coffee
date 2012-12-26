$(document).ready ->

  #slider
  $('#slider').cycle
    fx:'fade'
    timeout:7200
    random:1

  $.get '/mycard/download.url', (data)->
    if data.match(/mycard-(.*)-win32\.7z/)
      $('#download_version').html v[1]
    else
      $('#download_version').html '读取失败'
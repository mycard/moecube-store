$(document).ready ->

  #slider
  $('#slider').cycle
    fx:'fade'
    timeout:7200
    random:1

  $.get 'https://api.github.com/repos/zh99998/mycard/downloads?callbak=?', (data)->
    for download in data
      if v = download.name.match(/mycard-(.*)-win32\.7z/)
        if !version or v[1] > version
          version = v[1]
          url = download.html_url
    if version
      $('#download_url').attr 'href', url
      $('#download_version').html version
    else
      $('#download_version').html '读取失败'
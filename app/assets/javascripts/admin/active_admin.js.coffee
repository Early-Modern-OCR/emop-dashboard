#= require active_admin/base
$ ->
  $('a[confirm]').click (event)->
    message = $(this).attr 'confirm'
    if confirm message
      true
    else
      false

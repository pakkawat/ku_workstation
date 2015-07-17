# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

refreshPartial = ->
  $.ajax url: 'refresh_part'
  return

$(document).ready ->
  # will call refreshPartial every 1 seconds
  setInterval refreshPartial, 1000
  return

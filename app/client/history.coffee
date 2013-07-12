#### *module* history
#
# Надстройка над historyAPI, необходима для создания событий истории, это хорошо понижает связность модулей.
# Кроме событий, модуль возвращает false, если historyAPI недоступно, это используется другими модулями, которые зависят от этого,
# в дальнейшем такое поведение нужно бы реализовать с помощью requirejs loaderAPI (например так сделано с модулем dom)
#

define ['events'], (events) ->
  return false if not window.history or not window.history.pushState

  ###
    Workaround with Chrome popsate on very first page load. Get idea from jquery.pjax
  ###
  initialUrl = window.location.href
  popped = 'state' in window.history

  originOnpopstate = window.onpopstate
  window.onpopstate = (popStateEvent)->
    initialPop = !popped and location.href is initialUrl
    popped = true
    return if initialPop

    console.debug("here we are")
    if originOnpopstate?
      originOnpopstate.apply window, arguments

    events.trigger "history:popState", popStateEvent.state if popStateEvent.state?

  originPushState = window.history.pushState

  window.history.pushState = ->
    originPushState.apply window.history, arguments
    events.trigger "history:pushState", Array::slice.call arguments

  originReplaceState = window.history.pushState

  window.history.replaceState = ->
    originReplaceState.apply window.history, arguments
    events.trigger "history:replaceState", Array::slice.call Array, arguments

  return window.history
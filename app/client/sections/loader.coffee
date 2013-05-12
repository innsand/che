#### *module* sections/loader
#
# Загрузчик секций с сервера, данные о небходимых секциях
# отправляются в хидере "X-Che-Sections", это необходимо, чтобы
# точно отличать остальные запросы от запросов за секциями,
# так как согласно основной идее эти запросы отправляются всегда
# на разные url
#
define ["ajax", "events"], (ajax, events) ->
  sectionsRequest = null

  #### Интерфейс модуля: (url, method, sectionsHeader, index, data) ->
  #
  # Кроме данных об пути, методе и необходимых секциях,
  # принимает параметр index, который добавляется к загруженным данным,
  # необходим для точного встраивания секций в цепь переходов, так как
  # могут быть запрошены данные для переходов в середине цепи
  #
  (url, method, sectionsHeader, index, data = []) ->
    getState = (url, sections) ->
      url: url
      header: sectionsHeader
      index: index
      method: method
      sections: sections

    sectionsRequest?.abort()
    sectionsRequest = ajax.dispatch
      url: url,
      method: method,
      data: data,
      headers:
        "X-Che-Sections": sectionsHeader
        "X-Che": true
      type: "text"
      error: (request) ->
        state = getState url, sectionsHeader
        events.trigger "sections:error", [state, request.status, request.statusText]

    sectionsRequest.success (request, sections) ->
      state = getState (request.getResponseHeader "X-Che-Url"), sections
      events.trigger "sections:loaded", state

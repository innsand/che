#### *module* dom
#
# Содержит вспомогательные функции для обхода DOM-дерева, и навешивания обработчиков событий, чтобы не грузить большой jquery ради пары мелких задач
#

# Требует модуль 'utils/guid', для генерации уникальных id обработчиков событий

define ["utils/guid"], (guid) ->

  
  #### checkIsElementMatchSelector(selector, element, [root])
  #
  # Проверяет, подходит ли указанный селектор для элемента
  
  checkIsElementMatchSelector = (selector, element, root) ->
    listOfElemevents = domQuery(root or document).find(selector).get()
    _.find listOfElemevents, (elementFromlist) ->
      _.isEqual(elementFromlist, element)

  
  #### callEventHandlers(handlers, eventObj)
  #
  # Асинхронно вызывает обработчиков событий
  
  callEventHandlers = (handlers, eventObj) ->
    _.each handlers, (handler) ->
      _.delay(handler, eventObj)
        

  
  #### query(selector, [root])
  #
  # Возвращает элементы для указанного селектора
  #
  query = (selector, root) ->
    if window.jQuery
      query = (selector, root) ->
        return window.jQuery(root or document).find(selector).get()

      return query.apply this, arguments

    if document.querySelectorAll?
      if _.isString selector
        root = if not root or root.length is 0 then document else root
        if not root.length
          root = [root]
        result = []
        _.each root, (root) ->
          result = result.concat(Array.prototype.slice.call root.querySelectorAll(selector))
        return result
      else 
        return selector
    else
      console?.log "haven't tools for selecting node (module helpers/dom)"

  
  #### unbindEvent(node, eventName, handler)
  #
  # Отвязывает обработчика события для указанного DOM-элемента
  #
  unbindEvent =  ->


  
  #### bindEvent(node, eventName, handler)
  #
  # Привязывает обработчик события для указанного DOM-элемента
  #
  bindEvent = (node, eventName, handler) ->
    if node.addEventListener
      bindEvent = (node, eventName, handler) ->
        node.addEventListener eventName, handler, false
      unbindEvent = (node, eventName, handler) ->
        node.removeEventListener eventName, handler, false
    else if node.attachEvent
      bindEvent = (node, eventName, handler) ->
        node.attachEvent "on" + eventName, handler
      unbindEvent = (node, eventName, handler) ->
        node.detachEvent eventName, handler
    else
      bindEvent = ->
        console?.log "cannot bind event (module helpers/dom)"

    bindEvent.apply this, arguments

  
  
  #### delegateEvent(node, selector, eventName, handler)
  #
  # Привязывает обработчика события на DOM-элемент, делегирует ему события с элементов по селектору
  #
  delegateEvent = (node, selector, eventName, handler) ->
    if not node.domQueryDelegateHandler
      delegateHandler = (e) ->

        eventObject = e or window.event
        target = eventObject.target or eventObject.srcElement
        if target.nodeType is 3 # defeat Safari bug
          target = target.parentNode
      
        if node.domQueryHandlers[eventObject.type]
          handlers = node.domQueryHandlers[eventObject.type]
          _.each handlers, (handlers, selector) ->
            if checkIsElementMatchSelector selector, target
              callEventHandlers handlers, eventObject

      bindEvent node, eventName, delegateHandler
      node.domQueryDelegateHandler = delegateHandler

    handler.guid = handler.guid or guid()
    node.domQueryHandlers = node.domQueryHandlers or {}
    node.domQueryHandlers[eventName] = node.domQueryHandlers[eventName] or {}
    node.domQueryHandlers[eventName][selector] = node.domQueryHandlers[eventName][selector] or []
    node.domQueryHandlers[eventName][selector].push handler


  
  #### undelegateEvent(node, selector, eventName, handler)
  #
  # Отвязывает обработчика от делегирования событий с элементов по селектору
  #
  undelegateEvent = (node, selector, eventName, handler) ->
    return false if not handler.guid
    return false if not node.domQueryHandlers
    return false if not node.domQueryHandlers[eventName]
    return false if not node.domQueryHandlers[eventName][selector]
    handlers = node.domQueryHandlers[eventName][selector]
    index = null
    _.find handlers, (delegateHandler, handlerIndex) ->
      index = handlerIndex
      delegateHandler.guid is handler.guid

    if index
      node.domQueryHandlers[eventName][selector] handlers.splice index, 1


  
  #### domQuery([selector])
  #
  # Конструктор domQuery для работы с DOM-элементами
  #

  domQuery = (selector) ->
    if this instanceof domQuery
      return selector if selector instanceof domQuery
      elements = if _.isString(selector) then query selector else selector or []
      self = @
      if elements.length is undefined
        elements = [elements]
      @length = elements.length
      _.each elements, (element, index) ->
        self[index] = element
    else
      new domQuery selector

  domQuery:: =

    
    #### domQuery.prototype.on([selector], eventName, handler)
    #
    # Привязывает обработчика событий на элемент, либо для делегирования событий с элемента по селектору
    #
    on: (selector, eventName, handler) ->
      binder = if arguments.length is 3 then delegateEvent else bindEvent
      args = Array.prototype.slice.call(arguments)
      _.each @get() , (node, index) ->
        binder.apply @, [node].concat(args)

    
    #### domQuery.prototype.off([selector], eventName, handler)
    #
    # Отключает обработчика событий элемента, либо от делегирования событий с элемента по селектору
    #
    off: (selector, eventName, handler) ->
      unbinder = if arguments.length is 3 then undelegateEvent else unbindEvent
      args = Array.prototype.slice.call(arguments)
      _.each @get(), (node, index) ->
        unbinder.apply @, [node].concat(args)

    
    #### domQuery.prototype.find(selector)
    #
    # Возвращает элемент по селектору в контексте экземпляра domQuery
    #
    find: (selector) ->
      return domQuery query selector, @get()


    
    #### domQuery.prototype.get([index])
    #
    # Возвращает элемент по идексу, либо массив элементов экземпляра domQuery
    #
    get: (index) ->
      if index?
        index = Math.max 0, Math.min index, @length - 1
        @[index]
      else
        return Array.prototype.slice.call @
        
        
  domQuery
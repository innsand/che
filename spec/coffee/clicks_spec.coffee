describe "clicks module", ->
  anchors = events = clicks = null

  require [
    'events',
    'clicks/anchors',
    'clicks'
    ], (eventsModule, anchorsModule, clicksModule) ->
    events = eventsModule
    anchors = anchorsModule
    clicks = clicksModule

  beforeEach ->
    clicks.reset()
    waitsFor ->
      anchors?

  describe "anchor clicking", ->
    triggerMouseEvent = null
    eventsList = null


    beforeEach ->
      eventsList = events.list
      jasmine.Clock.useMock()
      triggerMouseEvent = (eventName, element) ->
        if document.createEvent
          event = document.createEvent "MouseEvents"
          event.initEvent eventName, true, true
        else
          event = document.createEventObject()
          event.eventType = eventName

        event.eventName = eventName
        event.memo = {}

        if document.createEvent
          element.dispatchEvent event
        else
          element.fireEvent "on" + event.eventType, event
      events.list = {}
      affix "a[data-reload-sections='testData']"
      affix "a[data-something-else]"

    afterEach ->
      events.list = eventsList

    it "should trigger pageTransition:init event, when have attr with reload sections params", ->
      handler = jasmine.createSpy("handler")

      events.bind "pageTransition:init", ->
        handler arguments

      triggerMouseEvent "click", $("a[data-reload-sections]")[0]

      jasmine.Clock.tick(1000000)

      expect(handler).toHaveBeenCalled()
      expect(handler.mostRecentCall.args[0][0]).toBe(null)
      expect(handler.mostRecentCall.args[0][1]).toBe("'testData'")
      expect(handler.mostRecentCall.args[0][2]).toBe("GET")

    it "should not call handler, when have attr with reload sections params", ->
      handler = jasmine.createSpy("handler")

      events.bind "pageTransition:init", ->
        handler arguments

      triggerMouseEvent "click", $("a[data-something-else]")[0]

      jasmine.Clock.tick(1000)

      expect(handler).not.toHaveBeenCalled()


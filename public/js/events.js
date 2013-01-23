(function() {

  define([], function() {
    var Events, Oops;
    Oops = function(name) {
      this.name = name;
      this._handlers = {};
      return this;
    };
    Oops.prototype = {
      _data: function() {
        return {
          name: this.name
        };
      },
      _handlerCaller: function(handler) {
        var result;
        result = handler.apply(handler.context, this._lastArgs);
        if (result === false) {
          return this._handlersCallOrder = [];
        }
      },
      _nextHandlerCall: function() {
        var handler, handlerId, self;
        handlerId = this._handlersCallOrder.shift();
        if (handlerId) {
          handler = this._handlers[handlerId];
          self = this;
          if (handler.options.isSync) {
            this._handlerCaller(handler);
          } else {
            _.delay(function() {
              return self._handlerCaller(handler);
            });
          }
          return this._nextHandlerCall();
        }
      },
      dispatch: function(args) {
        this._handlersCallOrder = _.keys(this._handlers).sort();
        this._lastArgs = _.isArray(args) ? args : [args];
        this._lastArgs.push(this._data());
        this._nextHandlerCall();
        return this;
      },
      bind: function(handler, context, options) {
        handler.id = handler.id || +_.uniqueId();
        handler.context = context;
        handler.options = handler.options || options || {};
        this._handlers[handler.id] = handler;
        if (handler.options.recall && this._lastArgs) {
          this._handlerCaller(handler);
        }
        return this;
      },
      once: function(handler, context, options) {
        var onceHandler, self;
        self = this;
        onceHandler = function() {
          self.unbind(onceHandler);
          return handler.apply(this, arguments);
        };
        this.bind(onceHandler, context, options);
        return this;
      },
      unbind: function(handler) {
        var id;
        id = handler.id;
        if (id && this._handlers[id]) {
          delete this._handlers[id];
        }
        return this;
      }
    };
    window.evnts = [];
    Events = function(_id) {
      this._id = _id;
      this.list = {};
      return this;
    };
    Events.prototype = {
      sprout: function(name) {
        var instance;
        instance = new Events();
        if (name != null) {
          this[name] = instance;
        }
        return instance;
      },
      create: function(name) {
        if (this._id === "root") {
          window.evnts.push(_.keys(this.list).join(""));
        }
        return this.list[name] = this.list[name] || new Oops(name);
      },
      once: function(name, handler, context, options) {
        return this.create(name).once(handler, context, options);
      },
      bind: function(eventsNames, handler, context, options) {
        var bindEventsList, compoundArguments, eventHandler, eventName, self, undispatchedEvents, _fn, _i, _len;
        bindEventsList = _.compact(eventsNames.split(/\,+\s*|\s+/));
        if (/\,+/.test(eventsNames)) {
          compoundArguments = {};
          undispatchedEvents = bindEventsList.concat([]);
          eventHandler = function() {
            var eventData;
            eventData = _.last(arguments);
            compoundArguments[eventData.name] = arguments;
            if (_.contains(undispatchedEvents, eventData.name)) {
              undispatchedEvents = _.without(undispatchedEvents, eventData.name);
            }
            if (undispatchedEvents.length === 0) {
              undispatchedEvents = bindEventsList.concat([]);
              return handler.call(this, compoundArguments);
            }
          };
        } else {
          eventHandler = handler;
        }
        self = this;
        _fn = function(eventName) {
          return self.create(eventName).bind(eventHandler, context, options);
        };
        for (_i = 0, _len = bindEventsList.length; _i < _len; _i++) {
          eventName = bindEventsList[_i];
          _fn(eventName);
        }
        return this.create(bindEventsList[0]);
      },
      unbind: function(name, handler) {
        if (this.list[name]) {
          return this.list[name].unbind(handler);
        }
      },
      trigger: function(name, args) {
        return this.create(name).dispatch(args);
      }
    };
    return new Events("root");
  });

}).call(this);
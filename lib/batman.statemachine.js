(function() {
  var Batman,
    __slice = [].slice;

  Batman = function() {
    var mixins;
    mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(Batman.Object, mixins, function(){});
  };

  Batman.version = '0.13.1';

  Batman.config = {
    pathPrefix: '/',
    viewPrefix: 'views',
    fetchRemoteViews: true,
    usePushState: false,
    minificationErrors: true
  };

  (Batman.container = (function() {
    return this;
  })()).Batman = Batman;

  if (typeof define === 'function') {
    define('batman', [], function() {
      return Batman;
    });
  }

  Batman.exportHelpers = function(onto) {
    var k, _i, _len, _ref;
    _ref = ['mixin', 'extend', 'unmixin', 'redirect', 'typeOf', 'redirect', 'setImmediate', 'clearImmediate'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      k = _ref[_i];
      onto["$" + k] = Batman[k];
    }
    return onto;
  };

  Batman.exportGlobals = function() {
    return Batman.exportHelpers(Batman.container);
  };

}).call(this);

(function() {
  var _Batman;

  Batman._Batman = _Batman = (function() {

    function _Batman(object) {
      this.object = object;
    }

    _Batman.prototype.check = function(object) {
      if (object !== this.object) {
        object._batman = new Batman._Batman(object);
        return false;
      }
      return true;
    };

    _Batman.prototype.get = function(key) {
      var reduction, results;
      results = this.getAll(key);
      switch (results.length) {
        case 0:
          return void 0;
        case 1:
          return results[0];
        default:
          reduction = results[0].concat != null ? function(a, b) {
            return a.concat(b);
          } : results[0].merge != null ? function(a, b) {
            return a.merge(b);
          } : results.every(function(x) {
            return typeof x === 'object';
          }) ? (results.unshift({}), function(a, b) {
            return Batman.extend(a, b);
          }) : void 0;
          if (reduction) {
            return results.reduceRight(reduction);
          } else {
            return results;
          }
      }
    };

    _Batman.prototype.getFirst = function(key) {
      var results;
      results = this.getAll(key);
      return results[0];
    };

    _Batman.prototype.getAll = function(keyOrGetter) {
      var getter, results, val;
      if (typeof keyOrGetter === 'function') {
        getter = keyOrGetter;
      } else {
        getter = function(ancestor) {
          var _ref;
          return (_ref = ancestor._batman) != null ? _ref[keyOrGetter] : void 0;
        };
      }
      results = this.ancestors(getter);
      if (val = getter(this.object)) {
        results.unshift(val);
      }
      return results;
    };

    _Batman.prototype.ancestors = function(getter) {
      var ancestor, results, val, _i, _len, _ref;
      this._allAncestors || (this._allAncestors = this.allAncestors());
      if (getter) {
        results = [];
        _ref = this._allAncestors;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ancestor = _ref[_i];
          val = getter(ancestor);
          if (val != null) {
            results.push(val);
          }
        }
        return results;
      } else {
        return this._allAncestors;
      }
    };

    _Batman.prototype.allAncestors = function() {
      var isClass, parent, proto, results, _ref, _ref1;
      results = [];
      isClass = !!this.object.prototype;
      parent = isClass ? (_ref = this.object.__super__) != null ? _ref.constructor : void 0 : (proto = Object.getPrototypeOf(this.object)) === this.object ? this.object.constructor.__super__ : proto;
      if (parent != null) {
        if ((_ref1 = parent._batman) != null) {
          _ref1.check(parent);
        }
        results.push(parent);
        if (parent._batman != null) {
          results = results.concat(parent._batman.allAncestors());
        }
      }
      return results;
    };

    _Batman.prototype.set = function(key, value) {
      return this[key] = value;
    };

    return _Batman;

  })();

}).call(this);

(function() {
  var chr, _encodedChars, _encodedCharsPattern, _entityMap, _implementImmediates, _objectToString, _unsafeChars, _unsafeCharsPattern,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Batman.typeOf = function(object) {
    if (typeof object === 'undefined') {
      return "Undefined";
    }
    return _objectToString.call(object).slice(8, -1);
  };

  _objectToString = Object.prototype.toString;

  Batman.extend = function() {
    var key, object, objects, to, value, _i, _len;
    to = arguments[0], objects = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_i = 0, _len = objects.length; _i < _len; _i++) {
      object = objects[_i];
      for (key in object) {
        value = object[key];
        to[key] = value;
      }
    }
    return to;
  };

  Batman.mixin = function() {
    var hasSet, key, mixin, mixins, to, value, _i, _len;
    to = arguments[0], mixins = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    hasSet = typeof to.set === 'function';
    for (_i = 0, _len = mixins.length; _i < _len; _i++) {
      mixin = mixins[_i];
      if (Batman.typeOf(mixin) !== 'Object') {
        continue;
      }
      for (key in mixin) {
        if (!__hasProp.call(mixin, key)) continue;
        value = mixin[key];
        if (key === 'initialize' || key === 'uninitialize' || key === 'prototype') {
          continue;
        }
        if (hasSet) {
          to.set(key, value);
        } else if (to.nodeName != null) {
          Batman.data(to, key, value);
        } else {
          to[key] = value;
        }
      }
      if (typeof mixin.initialize === 'function') {
        mixin.initialize.call(to);
      }
    }
    return to;
  };

  Batman.unmixin = function() {
    var from, key, mixin, mixins, _i, _len;
    from = arguments[0], mixins = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_i = 0, _len = mixins.length; _i < _len; _i++) {
      mixin = mixins[_i];
      for (key in mixin) {
        if (key === 'initialize' || key === 'uninitialize') {
          continue;
        }
        delete from[key];
      }
      if (typeof mixin.uninitialize === 'function') {
        mixin.uninitialize.call(from);
      }
    }
    return from;
  };

  Batman._functionName = Batman.functionName = function(f) {
    var _ref;
    if (f.__name__) {
      return f.__name__;
    }
    if (f.name) {
      return f.name;
    }
    return (_ref = f.toString().match(/\W*function\s+([\w\$]+)\(/)) != null ? _ref[1] : void 0;
  };

  Batman._isChildOf = Batman.isChildOf = function(parentNode, childNode) {
    var node;
    node = childNode.parentNode;
    while (node) {
      if (node === parentNode) {
        return true;
      }
      node = node.parentNode;
    }
    return false;
  };

  _implementImmediates = function(container) {
    var canUsePostMessage, count, functions, getHandle, handler, prefix, tasks;
    canUsePostMessage = function() {
      var async, oldMessage;
      if (!container.postMessage) {
        return false;
      }
      async = true;
      oldMessage = container.onmessage;
      container.onmessage = function() {
        return async = false;
      };
      container.postMessage("", "*");
      container.onmessage = oldMessage;
      return async;
    };
    tasks = new Batman.SimpleHash;
    count = 0;
    getHandle = function() {
      return "go" + (++count);
    };
    if (container.setImmediate && container.clearImmediate) {
      Batman.setImmediate = container.setImmediate;
      return Batman.clearImmediate = container.clearImmediate;
    } else if (canUsePostMessage()) {
      prefix = 'com.batman.';
      functions = new Batman.SimpleHash;
      handler = function(e) {
        var handle, _base;
        if (!~e.data.search(prefix)) {
          return;
        }
        handle = e.data.substring(prefix.length);
        return typeof (_base = tasks.unset(handle)) === "function" ? _base() : void 0;
      };
      if (container.addEventListener) {
        container.addEventListener('message', handler, false);
      } else {
        container.attachEvent('onmessage', handler);
      }
      Batman.setImmediate = function(f) {
        var handle;
        tasks.set(handle = getHandle(), f);
        container.postMessage(prefix + handle, "*");
        return handle;
      };
      return Batman.clearImmediate = function(handle) {
        return tasks.unset(handle);
      };
    } else if (typeof document !== 'undefined' && __indexOf.call(document.createElement("script"), "onreadystatechange") >= 0) {
      Batman.setImmediate = function(f) {
        var handle, script;
        handle = getHandle();
        script = document.createElement("script");
        script.onreadystatechange = function() {
          var _base;
          if (typeof (_base = tasks.get(handle)) === "function") {
            _base();
          }
          script.onreadystatechange = null;
          script.parentNode.removeChild(script);
          return script = null;
        };
        document.documentElement.appendChild(script);
        return handle;
      };
      return Batman.clearImmediate = function(handle) {
        return tasks.unset(handle);
      };
    } else if (typeof process !== "undefined" && process !== null ? process.nextTick : void 0) {
      functions = {};
      Batman.setImmediate = function(f) {
        var handle;
        handle = getHandle();
        functions[handle] = f;
        process.nextTick(function() {
          if (typeof functions[handle] === "function") {
            functions[handle]();
          }
          return delete functions[handle];
        });
        return handle;
      };
      return Batman.clearImmediate = function(handle) {
        return delete functions[handle];
      };
    } else {
      Batman.setImmediate = function(f) {
        return setTimeout(f, 0);
      };
      return Batman.clearImmediate = function(handle) {
        return clearTimeout(handle);
      };
    }
  };

  Batman.setImmediate = function() {
    _implementImmediates(Batman.container);
    return Batman.setImmediate.apply(this, arguments);
  };

  Batman.clearImmediate = function() {
    _implementImmediates(Batman.container);
    return Batman.clearImmediate.apply(this, arguments);
  };

  Batman.forEach = function(container, iterator, ctx) {
    var e, i, k, v, _i, _len, _results, _results1;
    if (container.forEach) {
      return container.forEach(iterator, ctx);
    } else if (container.indexOf) {
      _results = [];
      for (i = _i = 0, _len = container.length; _i < _len; i = ++_i) {
        e = container[i];
        _results.push(iterator.call(ctx, e, i, container));
      }
      return _results;
    } else {
      _results1 = [];
      for (k in container) {
        v = container[k];
        _results1.push(iterator.call(ctx, k, v, container));
      }
      return _results1;
    }
  };

  Batman.objectHasKey = function(object, key) {
    if (typeof object.hasKey === 'function') {
      return object.hasKey(key);
    } else {
      return key in object;
    }
  };

  Batman.contains = function(container, item) {
    if (container.indexOf) {
      return __indexOf.call(container, item) >= 0;
    } else if (typeof container.has === 'function') {
      return container.has(item);
    } else {
      return Batman.objectHasKey(container, item);
    }
  };

  Batman.get = function(base, key) {
    if (typeof base.get === 'function') {
      return base.get(key);
    } else {
      return Batman.Property.forBaseAndKey(base, key).getValue();
    }
  };

  Batman.getPath = function(base, segments) {
    var segment, _i, _len;
    for (_i = 0, _len = segments.length; _i < _len; _i++) {
      segment = segments[_i];
      if (base != null) {
        base = Batman.get(base, segment);
        if (base == null) {
          return base;
        }
      } else {
        return void 0;
      }
    }
    return base;
  };

  _entityMap = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    "\"": "&#34;",
    "'": "&#39;"
  };

  _unsafeChars = [];

  _encodedChars = [];

  for (chr in _entityMap) {
    _unsafeChars.push(chr);
    _encodedChars.push(_entityMap[chr]);
  }

  _unsafeCharsPattern = new RegExp("[" + (_unsafeChars.join('')) + "]", "g");

  _encodedCharsPattern = new RegExp("(" + (_encodedChars.join('|')) + ")", "g");

  Batman.escapeHTML = (function() {
    return function(s) {
      return ("" + s).replace(_unsafeCharsPattern, function(c) {
        return _entityMap[c];
      });
    };
  })();

  Batman.unescapeHTML = (function() {
    return function(s) {
      var node;
      if (s == null) {
        return;
      }
      node = Batman._unescapeHTMLNode || (Batman._unescapeHTMLNode = document.createElement('DIV'));
      node.innerHTML = s;
      if (node.innerText != null) {
        return node.innerText;
      } else {
        return node.textContent;
      }
    };
  })();

  Batman.translate = function(x, values) {
    if (values == null) {
      values = {};
    }
    return Batman.helpers.interpolate(Batman.get(Batman.translate.messages, x), values);
  };

  Batman.translate.messages = {};

  Batman.t = function() {
    return Batman.translate.apply(Batman, arguments);
  };

  Batman.redirect = function(url) {
    var _ref;
    return (_ref = Batman.navigator) != null ? _ref.redirect(url) : void 0;
  };

  Batman.initializeObject = function(object) {
    if (object._batman != null) {
      return object._batman.check(object);
    } else {
      return object._batman = new Batman._Batman(object);
    }
  };

}).call(this);

(function() {

  Batman.Event = (function() {

    Event.forBaseAndKey = function(base, key) {
      if (base.isEventEmitter) {
        return base.event(key);
      } else {
        return new Batman.Event(base, key);
      }
    };

    function Event(base, key) {
      this.base = base;
      this.key = key;
      this._preventCount = 0;
    }

    Event.prototype.isEvent = true;

    Event.prototype.isEqual = function(other) {
      return this.constructor === other.constructor && this.base === other.base && this.key === other.key;
    };

    Event.prototype.hashKey = function() {
      var key;
      this.hashKey = function() {
        return key;
      };
      return key = "<Batman.Event base: " + (Batman.Hash.prototype.hashKeyFor(this.base)) + ", key: \"" + (Batman.Hash.prototype.hashKeyFor(this.key)) + "\">";
    };

    Event.prototype.addHandler = function(handler) {
      this.handlers || (this.handlers = []);
      if (this.handlers.indexOf(handler) === -1) {
        this.handlers.push(handler);
      }
      if (this.oneShot) {
        this.autofireHandler(handler);
      }
      return this;
    };

    Event.prototype.removeHandler = function(handler) {
      var index;
      if (this.handlers && (index = this.handlers.indexOf(handler)) !== -1) {
        this.handlers.splice(index, 1);
      }
      return this;
    };

    Event.prototype.eachHandler = function(iterator) {
      var ancestor, key, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _results;
      if ((_ref = this.handlers) != null) {
        _ref.slice().forEach(iterator);
      }
      if ((_ref1 = this.base) != null ? _ref1.isEventEmitter : void 0) {
        key = this.key;
        _ref3 = (_ref2 = this.base._batman) != null ? _ref2.ancestors() : void 0;
        _results = [];
        for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
          ancestor = _ref3[_i];
          if (ancestor.isEventEmitter && ((_ref4 = ancestor._batman) != null ? (_ref5 = _ref4.events) != null ? _ref5.hasOwnProperty(key) : void 0 : void 0)) {
            _results.push((_ref6 = ancestor.event(key, false)) != null ? (_ref7 = _ref6.handlers) != null ? _ref7.slice().forEach(iterator) : void 0 : void 0);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    };

    Event.prototype.clearHandlers = function() {
      return this.handlers = void 0;
    };

    Event.prototype.handlerContext = function() {
      return this.base;
    };

    Event.prototype.prevent = function() {
      return ++this._preventCount;
    };

    Event.prototype.allow = function() {
      if (this._preventCount) {
        --this._preventCount;
      }
      return this._preventCount;
    };

    Event.prototype.isPrevented = function() {
      return this._preventCount > 0;
    };

    Event.prototype.autofireHandler = function(handler) {
      if (this._oneShotFired && (this._oneShotArgs != null)) {
        return handler.apply(this.handlerContext(), this._oneShotArgs);
      }
    };

    Event.prototype.resetOneShot = function() {
      this._oneShotFired = false;
      return this._oneShotArgs = null;
    };

    Event.prototype.fire = function() {
      return this.fireWithContext(this.handlerContext(), arguments);
    };

    Event.prototype.fireWithContext = function(context, args) {
      if (this.isPrevented() || this._oneShotFired) {
        return false;
      }
      if (this.oneShot) {
        this._oneShotFired = true;
        this._oneShotArgs = args;
      }
      return this.eachHandler(function(handler) {
        return handler.apply(context, args);
      });
    };

    Event.prototype.allowAndFire = function() {
      return this.allowAndFireWithContext(this.handlerContext, arguments);
    };

    Event.prototype.allowAndFireWithContext = function(context, args) {
      this.allow();
      return this.fireWithContext(context, args);
    };

    return Event;

  })();

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Batman.PropertyEvent = (function(_super) {

    __extends(PropertyEvent, _super);

    function PropertyEvent() {
      return PropertyEvent.__super__.constructor.apply(this, arguments);
    }

    PropertyEvent.prototype.eachHandler = function(iterator) {
      return this.base.eachObserver(iterator);
    };

    PropertyEvent.prototype.handlerContext = function() {
      return this.base.base;
    };

    return PropertyEvent;

  })(Batman.Event);

}).call(this);

(function() {
  var __slice = [].slice;

  Batman.EventEmitter = {
    isEventEmitter: true,
    hasEvent: function(key) {
      var _ref, _ref1;
      return (_ref = this._batman) != null ? typeof _ref.get === "function" ? (_ref1 = _ref.get('events')) != null ? _ref1.hasOwnProperty(key) : void 0 : void 0 : void 0;
    },
    event: function(key, createEvent) {
      var ancestor, eventClass, events, existingEvent, newEvent, _base, _i, _len, _ref, _ref1, _ref2, _ref3;
      if (createEvent == null) {
        createEvent = true;
      }
      Batman.initializeObject(this);
      eventClass = this.eventClass || Batman.Event;
      if ((_ref = this._batman.events) != null ? _ref.hasOwnProperty(key) : void 0) {
        return existingEvent = this._batman.events[key];
      } else {
        _ref1 = this._batman.ancestors();
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          ancestor = _ref1[_i];
          existingEvent = (_ref2 = ancestor._batman) != null ? (_ref3 = _ref2.events) != null ? _ref3[key] : void 0 : void 0;
          if (existingEvent) {
            break;
          }
        }
        if (createEvent || (existingEvent != null ? existingEvent.oneShot : void 0)) {
          events = (_base = this._batman).events || (_base.events = {});
          newEvent = events[key] = new eventClass(this, key);
          newEvent.oneShot = existingEvent != null ? existingEvent.oneShot : void 0;
          return newEvent;
        } else {
          return existingEvent;
        }
      }
    },
    on: function() {
      var handler, key, keys, _i, _j, _len, _results;
      keys = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), handler = arguments[_i++];
      _results = [];
      for (_j = 0, _len = keys.length; _j < _len; _j++) {
        key = keys[_j];
        _results.push(this.event(key).addHandler(handler));
      }
      return _results;
    },
    once: function(key, handler) {
      var event, handlerWrapper;
      event = this.event(key);
      handlerWrapper = function() {
        handler.apply(this, arguments);
        return event.removeHandler(handlerWrapper);
      };
      return event.addHandler(handlerWrapper);
    },
    registerAsMutableSource: function() {
      return Batman.Property.registerSource(this);
    },
    mutation: function(wrappedFunction) {
      return function() {
        var result, _ref;
        result = wrappedFunction.apply(this, arguments);
        if ((_ref = this.event('change', false)) != null) {
          _ref.fire(this, this);
        }
        return result;
      };
    },
    prevent: function(key) {
      this.event(key).prevent();
      return this;
    },
    allow: function(key) {
      this.event(key).allow();
      return this;
    },
    isPrevented: function(key) {
      var _ref;
      return (_ref = this.event(key, false)) != null ? _ref.isPrevented() : void 0;
    },
    fire: function() {
      var args, key, _ref;
      key = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = this.event(key, false)) != null ? _ref.fireWithContext(this, args) : void 0;
    },
    allowAndFire: function() {
      var args, key, _ref;
      key = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = this.event(key, false)) != null ? _ref.allowAndFireWithContext(this, args) : void 0;
    }
  };

}).call(this);

(function() {
  var __slice = [].slice;

  Batman.Enumerable = {
    isEnumerable: true,
    map: function(f, ctx) {
      var r;
      if (ctx == null) {
        ctx = Batman.container;
      }
      r = [];
      this.forEach(function() {
        return r.push(f.apply(ctx, arguments));
      });
      return r;
    },
    mapToProperty: function(key) {
      var r;
      r = [];
      this.forEach(function(item) {
        return r.push(item.get(key));
      });
      return r;
    },
    every: function(f, ctx) {
      var r;
      if (ctx == null) {
        ctx = Batman.container;
      }
      r = true;
      this.forEach(function() {
        return r = r && f.apply(ctx, arguments);
      });
      return r;
    },
    some: function(f, ctx) {
      var r;
      if (ctx == null) {
        ctx = Batman.container;
      }
      r = false;
      this.forEach(function() {
        return r = r || f.apply(ctx, arguments);
      });
      return r;
    },
    reduce: function(f, r) {
      var count, self;
      count = 0;
      self = this;
      this.forEach(function() {
        if (r != null) {
          return r = f.apply(null, [r].concat(__slice.call(arguments), [count], [self]));
        } else {
          return r = arguments[0];
        }
      });
      return r;
    },
    filter: function(f) {
      var r, wrap;
      r = new this.constructor;
      if (r.add) {
        wrap = function(r, e) {
          if (f(e)) {
            r.add(e);
          }
          return r;
        };
      } else if (r.set) {
        wrap = function(r, k, v) {
          if (f(k, v)) {
            r.set(k, v);
          }
          return r;
        };
      } else {
        if (!r.push) {
          r = [];
        }
        wrap = function(r, e) {
          if (f(e)) {
            r.push(e);
          }
          return r;
        };
      }
      return this.reduce(wrap, r);
    },
    inGroupsOf: function(n) {
      var current, i, r;
      r = [];
      current = false;
      i = 0;
      this.forEach(function(x) {
        if (i++ % n === 0) {
          current = [];
          r.push(current);
        }
        return current.push(x);
      });
      return r;
    }
  };

}).call(this);

(function() {
  var __slice = [].slice;

  Batman.SimpleHash = (function() {

    function SimpleHash(obj) {
      this._storage = {};
      this.length = 0;
      if (obj != null) {
        this.update(obj);
      }
    }

    Batman.extend(SimpleHash.prototype, Batman.Enumerable);

    SimpleHash.prototype.hasKey = function(key) {
      var pair, pairs, _i, _len;
      if (this.objectKey(key)) {
        if (!this._objectStorage) {
          return false;
        }
        if (pairs = this._objectStorage[this.hashKeyFor(key)]) {
          for (_i = 0, _len = pairs.length; _i < _len; _i++) {
            pair = pairs[_i];
            if (this.equality(pair[0], key)) {
              return true;
            }
          }
        }
        return false;
      } else {
        key = this.prefixedKey(key);
        return this._storage.hasOwnProperty(key);
      }
    };

    SimpleHash.prototype.get = function(key) {
      var pair, pairs, _i, _len;
      if (this.objectKey(key)) {
        if (!this._objectStorage) {
          return void 0;
        }
        if (pairs = this._objectStorage[this.hashKeyFor(key)]) {
          for (_i = 0, _len = pairs.length; _i < _len; _i++) {
            pair = pairs[_i];
            if (this.equality(pair[0], key)) {
              return pair[1];
            }
          }
        }
      } else {
        return this._storage[this.prefixedKey(key)];
      }
    };

    SimpleHash.prototype.set = function(key, val) {
      var pair, pairs, _base, _i, _len, _name;
      if (this.objectKey(key)) {
        this._objectStorage || (this._objectStorage = {});
        pairs = (_base = this._objectStorage)[_name = this.hashKeyFor(key)] || (_base[_name] = []);
        for (_i = 0, _len = pairs.length; _i < _len; _i++) {
          pair = pairs[_i];
          if (this.equality(pair[0], key)) {
            return pair[1] = val;
          }
        }
        this.length++;
        pairs.push([key, val]);
        return val;
      } else {
        key = this.prefixedKey(key);
        if (this._storage[key] == null) {
          this.length++;
        }
        return this._storage[key] = val;
      }
    };

    SimpleHash.prototype.unset = function(key) {
      var hashKey, index, obj, pair, pairs, val, value, _i, _len, _ref;
      if (this.objectKey(key)) {
        if (!this._objectStorage) {
          return void 0;
        }
        hashKey = this.hashKeyFor(key);
        if (pairs = this._objectStorage[hashKey]) {
          for (index = _i = 0, _len = pairs.length; _i < _len; index = ++_i) {
            _ref = pairs[index], obj = _ref[0], value = _ref[1];
            if (this.equality(obj, key)) {
              pair = pairs.splice(index, 1);
              if (!pairs.length) {
                delete this._objectStorage[hashKey];
              }
              this.length--;
              return pair[0][1];
            }
          }
        }
      } else {
        key = this.prefixedKey(key);
        val = this._storage[key];
        if (this._storage[key] != null) {
          this.length--;
          delete this._storage[key];
        }
        return val;
      }
    };

    SimpleHash.prototype.getOrSet = function(key, valueFunction) {
      var currentValue;
      currentValue = this.get(key);
      if (!currentValue) {
        currentValue = valueFunction();
        this.set(key, currentValue);
      }
      return currentValue;
    };

    SimpleHash.prototype.prefixedKey = function(key) {
      return "_" + key;
    };

    SimpleHash.prototype.unprefixedKey = function(key) {
      return key.slice(1);
    };

    SimpleHash.prototype.hashKeyFor = function(obj) {
      return (obj != null ? typeof obj.hashKey === "function" ? obj.hashKey() : void 0 : void 0) || obj;
    };

    SimpleHash.prototype.equality = function(lhs, rhs) {
      if (lhs === rhs) {
        return true;
      }
      if (lhs !== lhs && rhs !== rhs) {
        return true;
      }
      if ((lhs != null ? typeof lhs.isEqual === "function" ? lhs.isEqual(rhs) : void 0 : void 0) && (rhs != null ? typeof rhs.isEqual === "function" ? rhs.isEqual(lhs) : void 0 : void 0)) {
        return true;
      }
      return false;
    };

    SimpleHash.prototype.objectKey = function(key) {
      return typeof key !== 'string';
    };

    SimpleHash.prototype.forEach = function(iterator, ctx) {
      var key, obj, results, value, values, _i, _len, _ref, _ref1, _ref2, _ref3;
      results = [];
      if (this._objectStorage) {
        _ref = this._objectStorage;
        for (key in _ref) {
          values = _ref[key];
          _ref1 = values.slice();
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            _ref2 = _ref1[_i], obj = _ref2[0], value = _ref2[1];
            results.push(iterator.call(ctx, obj, value, this));
          }
        }
      }
      _ref3 = this._storage;
      for (key in _ref3) {
        value = _ref3[key];
        results.push(iterator.call(ctx, this.unprefixedKey(key), value, this));
      }
      return results;
    };

    SimpleHash.prototype.keys = function() {
      var result;
      result = [];
      Batman.SimpleHash.prototype.forEach.call(this, function(key) {
        return result.push(key);
      });
      return result;
    };

    SimpleHash.prototype.toArray = SimpleHash.prototype.keys;

    SimpleHash.prototype.clear = function() {
      this._storage = {};
      delete this._objectStorage;
      return this.length = 0;
    };

    SimpleHash.prototype.isEmpty = function() {
      return this.length === 0;
    };

    SimpleHash.prototype.merge = function() {
      var hash, merged, others, _i, _len;
      others = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      merged = new this.constructor;
      others.unshift(this);
      for (_i = 0, _len = others.length; _i < _len; _i++) {
        hash = others[_i];
        hash.forEach(function(obj, value) {
          return merged.set(obj, value);
        });
      }
      return merged;
    };

    SimpleHash.prototype.update = function(object) {
      var k, v, _results;
      _results = [];
      for (k in object) {
        v = object[k];
        _results.push(this.set(k, v));
      }
      return _results;
    };

    SimpleHash.prototype.replace = function(object) {
      var _this = this;
      this.forEach(function(key, value) {
        if (!(key in object)) {
          return _this.unset(key);
        }
      });
      return this.update(object);
    };

    SimpleHash.prototype.toObject = function() {
      var key, obj, pair, value, _ref, _ref1;
      obj = {};
      _ref = this._storage;
      for (key in _ref) {
        value = _ref[key];
        obj[this.unprefixedKey(key)] = value;
      }
      if (this._objectStorage) {
        _ref1 = this._objectStorage;
        for (key in _ref1) {
          pair = _ref1[key];
          obj[key] = pair[0][1];
        }
      }
      return obj;
    };

    SimpleHash.prototype.toJSON = SimpleHash.prototype.toObject;

    return SimpleHash;

  })();

}).call(this);

(function() {
  var __slice = [].slice;

  Batman.SimpleSet = (function() {

    function SimpleSet() {
      var item, itemsToAdd;
      this._storage = [];
      this.length = 0;
      itemsToAdd = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = arguments.length; _i < _len; _i++) {
          item = arguments[_i];
          if (item != null) {
            _results.push(item);
          }
        }
        return _results;
      }).apply(this, arguments);
      if (itemsToAdd.length > 0) {
        this.add.apply(this, itemsToAdd);
      }
    }

    Batman.extend(SimpleSet.prototype, Batman.Enumerable);

    SimpleSet.prototype.has = function(item) {
      return !!(~this._indexOfItem(item));
    };

    SimpleSet.prototype.add = function() {
      var addedItems, item, items, _i, _len;
      items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      addedItems = [];
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        if (!(!~this._indexOfItem(item))) {
          continue;
        }
        this._storage.push(item);
        addedItems.push(item);
      }
      this.length = this._storage.length;
      if (this.fire && addedItems.length !== 0) {
        this.fire('change', this, this);
        this.fire.apply(this, ['itemsWereAdded'].concat(__slice.call(addedItems)));
      }
      return addedItems;
    };

    SimpleSet.prototype.remove = function() {
      var index, item, items, removedItems, _i, _len;
      items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      removedItems = [];
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        if (!(~(index = this._indexOfItem(item)))) {
          continue;
        }
        this._storage.splice(index, 1);
        removedItems.push(item);
      }
      this.length = this._storage.length;
      if (this.fire && removedItems.length !== 0) {
        this.fire('change', this, this);
        this.fire.apply(this, ['itemsWereRemoved'].concat(__slice.call(removedItems)));
      }
      return removedItems;
    };

    SimpleSet.prototype.find = function(f) {
      var item, _i, _len, _ref;
      _ref = this._storage;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        if (f(item)) {
          return item;
        }
      }
    };

    SimpleSet.prototype.forEach = function(iterator, ctx) {
      var key, _i, _len, _ref, _results;
      _ref = this._storage;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        _results.push(iterator.call(ctx, key, null, this));
      }
      return _results;
    };

    SimpleSet.prototype.isEmpty = function() {
      return this.length === 0;
    };

    SimpleSet.prototype.clear = function() {
      var items;
      items = this._storage;
      this._storage = [];
      this.length = 0;
      if (this.fire && items.length !== 0) {
        this.fire('change', this, this);
        this.fire.apply(this, ['itemsWereRemoved'].concat(__slice.call(items)));
      }
      return items;
    };

    SimpleSet.prototype.replace = function(other) {
      try {
        if (typeof this.prevent === "function") {
          this.prevent('change');
        }
        this.clear();
        return this.add.apply(this, other.toArray());
      } finally {
        if (typeof this.allowAndFire === "function") {
          this.allowAndFire('change', this, this);
        }
      }
    };

    SimpleSet.prototype.toArray = function() {
      return this._storage.slice();
    };

    SimpleSet.prototype.merge = function() {
      var merged, others, set, _i, _len;
      others = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      merged = new this.constructor;
      others.unshift(this);
      for (_i = 0, _len = others.length; _i < _len; _i++) {
        set = others[_i];
        set.forEach(function(v) {
          return merged.add(v);
        });
      }
      return merged;
    };

    SimpleSet.prototype.indexedBy = function(key) {
      this._indexes || (this._indexes = new Batman.SimpleHash);
      return this._indexes.get(key) || this._indexes.set(key, new Batman.SetIndex(this, key));
    };

    SimpleSet.prototype.indexedByUnique = function(key) {
      this._uniqueIndexes || (this._uniqueIndexes = new Batman.SimpleHash);
      return this._uniqueIndexes.get(key) || this._uniqueIndexes.set(key, new Batman.UniqueSetIndex(this, key));
    };

    SimpleSet.prototype.sortedBy = function(key, order) {
      var sortsForKey;
      if (order == null) {
        order = "asc";
      }
      order = order.toLowerCase() === "desc" ? "desc" : "asc";
      this._sorts || (this._sorts = new Batman.SimpleHash);
      sortsForKey = this._sorts.get(key) || this._sorts.set(key, new Batman.Object);
      return sortsForKey.get(order) || sortsForKey.set(order, new Batman.SetSort(this, key, order));
    };

    SimpleSet.prototype.equality = Batman.SimpleHash.prototype.equality;

    SimpleSet.prototype._indexOfItem = function(givenItem) {
      var index, item, _i, _len, _ref;
      _ref = this._storage;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        item = _ref[index];
        if (this.equality(givenItem, item)) {
          return index;
        }
      }
      return -1;
    };

    return SimpleSet;

  })();

}).call(this);

(function() {
  var developer;

  Batman.developer = {
    suppressed: false,
    DevelopmentError: (function() {
      var DevelopmentError;
      DevelopmentError = function(message) {
        this.message = message;
        return this.name = "DevelopmentError";
      };
      DevelopmentError.prototype = Error.prototype;
      return DevelopmentError;
    })(),
    _ie_console: function(f, args) {
      var arg, _i, _len, _results;
      if (args.length !== 1) {
        if (typeof console !== "undefined" && console !== null) {
          console[f]("..." + f + " of " + args.length + " items...");
        }
      }
      _results = [];
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        arg = args[_i];
        _results.push(typeof console !== "undefined" && console !== null ? console[f](arg) : void 0);
      }
      return _results;
    },
    suppress: function(f) {
      developer.suppressed = true;
      if (f) {
        f();
        return developer.suppressed = false;
      }
    },
    unsuppress: function() {
      return developer.suppressed = false;
    },
    log: function() {
      if (developer.suppressed || !((typeof console !== "undefined" && console !== null ? console.log : void 0) != null)) {
        return;
      }
      if (console.log.apply) {
        return console.log.apply(console, arguments);
      } else {
        return developer._ie_console("log", arguments);
      }
    },
    warn: function() {
      if (developer.suppressed || !((typeof console !== "undefined" && console !== null ? console.warn : void 0) != null)) {
        return;
      }
      if (console.warn.apply) {
        return console.warn.apply(console, arguments);
      } else {
        return developer._ie_console("warn", arguments);
      }
    },
    error: function(message) {
      throw new developer.DevelopmentError(message);
    },
    assert: function(result, message) {
      if (!result) {
        return developer.error(message);
      }
    },
    "do": function(f) {
      if (!developer.suppressed) {
        return f();
      }
    },
    addFilters: function() {
      return Batman.extend(Batman.Filters, {
        log: function(value, key) {
          if (typeof console !== "undefined" && console !== null) {
            if (typeof console.log === "function") {
              console.log(arguments);
            }
          }
          return value;
        },
        logStack: function(value) {
          if (typeof console !== "undefined" && console !== null) {
            if (typeof console.log === "function") {
              console.log(developer.currentFilterStack);
            }
          }
          return value;
        }
      });
    }
  };

  developer = Batman.developer;

  Batman.developer.assert((function() {}).bind, "Error! Batman needs Function.bind to work! Please shim it using something like es5-shim or augmentjs!");

}).call(this);

(function() {
  var SOURCE_TRACKER_STACK, SOURCE_TRACKER_STACK_VALID,
    __slice = [].slice;

  SOURCE_TRACKER_STACK = [];

  SOURCE_TRACKER_STACK_VALID = true;

  Batman.Property = (function() {

    Batman.mixin(Property.prototype, Batman.EventEmitter);

    Property._sourceTrackerStack = SOURCE_TRACKER_STACK;

    Property._sourceTrackerStackValid = SOURCE_TRACKER_STACK_VALID;

    Property.defaultAccessor = {
      get: function(key) {
        return this[key];
      },
      set: function(key, val) {
        return this[key] = val;
      },
      unset: function(key) {
        var x;
        x = this[key];
        delete this[key];
        return x;
      },
      cache: false
    };

    Property.defaultAccessorForBase = function(base) {
      var _ref;
      return ((_ref = base._batman) != null ? _ref.getFirst('defaultAccessor') : void 0) || Batman.Property.defaultAccessor;
    };

    Property.accessorForBaseAndKey = function(base, key) {
      var accessor, ancestor, _bm, _i, _len, _ref, _ref1, _ref2, _ref3;
      if ((_bm = base._batman) != null) {
        accessor = (_ref = _bm.keyAccessors) != null ? _ref.get(key) : void 0;
        if (!accessor) {
          _ref1 = _bm.ancestors();
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            ancestor = _ref1[_i];
            accessor = (_ref2 = ancestor._batman) != null ? (_ref3 = _ref2.keyAccessors) != null ? _ref3.get(key) : void 0 : void 0;
            if (accessor) {
              break;
            }
          }
        }
      }
      return accessor || this.defaultAccessorForBase(base);
    };

    Property.forBaseAndKey = function(base, key) {
      if (base.isObservable) {
        return base.property(key);
      } else {
        return new Batman.Keypath(base, key);
      }
    };

    Property.withoutTracking = function(block) {
      return this.wrapTrackingPrevention(block)();
    };

    Property.wrapTrackingPrevention = function(block) {
      return function() {
        Batman.Property.pushDummySourceTracker();
        try {
          return block.apply(this, arguments);
        } finally {
          Batman.Property.popSourceTracker();
        }
      };
    };

    Property.registerSource = function(obj) {
      var set;
      if (!obj.isEventEmitter) {
        return;
      }
      if (SOURCE_TRACKER_STACK_VALID) {
        set = SOURCE_TRACKER_STACK[SOURCE_TRACKER_STACK.length - 1];
      } else {
        set = [];
        SOURCE_TRACKER_STACK.push(set);
        SOURCE_TRACKER_STACK_VALID = true;
      }
      if (set != null) {
        set.push(obj);
      }
      return void 0;
    };

    Property.pushSourceTracker = function() {
      if (SOURCE_TRACKER_STACK_VALID) {
        return SOURCE_TRACKER_STACK_VALID = false;
      } else {
        return SOURCE_TRACKER_STACK.push([]);
      }
    };

    Property.popSourceTracker = function() {
      if (SOURCE_TRACKER_STACK_VALID) {
        return SOURCE_TRACKER_STACK.pop();
      } else {
        SOURCE_TRACKER_STACK_VALID = true;
        return void 0;
      }
    };

    Property.pushDummySourceTracker = function() {
      if (!SOURCE_TRACKER_STACK_VALID) {
        SOURCE_TRACKER_STACK.push([]);
        SOURCE_TRACKER_STACK_VALID = true;
      }
      return SOURCE_TRACKER_STACK.push(null);
    };

    function Property(base, key) {
      this.base = base;
      this.key = key;
    }

    Property.prototype._isolationCount = 0;

    Property.prototype.cached = false;

    Property.prototype.value = null;

    Property.prototype.sources = null;

    Property.prototype.isProperty = true;

    Property.prototype.isDead = false;

    Property.prototype.eventClass = Batman.PropertyEvent;

    Property.prototype.isEqual = function(other) {
      return this.constructor === other.constructor && this.base === other.base && this.key === other.key;
    };

    Property.prototype.hashKey = function() {
      return this._hashKey || (this._hashKey = "<Batman.Property base: " + (Batman.Hash.prototype.hashKeyFor(this.base)) + ", key: \"" + (Batman.Hash.prototype.hashKeyFor(this.key)) + "\">");
    };

    Property.prototype.event = function(key) {
      var eventClass, _base;
      eventClass = this.eventClass || Batman.Event;
      this.events || (this.events = {});
      (_base = this.events)[key] || (_base[key] = new eventClass(this, key));
      return this.events[key];
    };

    Property.prototype.changeEvent = function() {
      return this._changeEvent || (this._changeEvent = this.event('change'));
    };

    Property.prototype.accessor = function() {
      return this._accessor || (this._accessor = this.constructor.accessorForBaseAndKey(this.base, this.key));
    };

    Property.prototype.eachObserver = function(iterator) {
      var ancestor, handlers, key, object, property, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results;
      key = this.key;
      handlers = (_ref = this.changeEvent().handlers) != null ? _ref.slice() : void 0;
      if (handlers) {
        for (_i = 0, _len = handlers.length; _i < _len; _i++) {
          object = handlers[_i];
          iterator(object);
        }
      }
      if (this.base.isObservable) {
        _ref1 = this.base._batman.ancestors();
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          ancestor = _ref1[_j];
          if (ancestor.isObservable && ancestor.hasProperty(key)) {
            property = ancestor.property(key);
            handlers = (_ref2 = property.changeEvent().handlers) != null ? _ref2.slice() : void 0;
            if (handlers) {
              _results.push((function() {
                var _k, _len2, _results1;
                _results1 = [];
                for (_k = 0, _len2 = handlers.length; _k < _len2; _k++) {
                  object = handlers[_k];
                  _results1.push(iterator(object));
                }
                return _results1;
              })());
            } else {
              _results.push(void 0);
            }
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    };

    Property.prototype.observers = function() {
      var results;
      results = [];
      this.eachObserver(function(observer) {
        return results.push(observer);
      });
      return results;
    };

    Property.prototype.hasObservers = function() {
      return this.observers().length > 0;
    };

    Property.prototype.updateSourcesFromTracker = function() {
      var handler, newSources, source, _i, _j, _len, _len1, _ref, _ref1, _results;
      newSources = this.constructor.popSourceTracker();
      handler = this.sourceChangeHandler();
      if (this.sources) {
        _ref = this.sources;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          source = _ref[_i];
          if (source != null) {
            source.event('change').removeHandler(handler);
          }
        }
      }
      this.sources = newSources;
      if (this.sources) {
        _ref1 = this.sources;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          source = _ref1[_j];
          _results.push(source != null ? source.event('change').addHandler(handler) : void 0);
        }
        return _results;
      }
    };

    Property.prototype.getValue = function() {
      this.registerAsMutableSource();
      if (!this.isCached()) {
        this.constructor.pushSourceTracker();
        try {
          this.value = this.valueFromAccessor();
          this.cached = true;
        } finally {
          this.updateSourcesFromTracker();
        }
      }
      return this.value;
    };

    Property.prototype.isCachable = function() {
      var cacheable;
      if (this.isFinal()) {
        return true;
      }
      cacheable = this.accessor().cache;
      if (cacheable != null) {
        return !!cacheable;
      } else {
        return true;
      }
    };

    Property.prototype.isCached = function() {
      return this.isCachable() && this.cached;
    };

    Property.prototype.isFinal = function() {
      return !!this.accessor()['final'];
    };

    Property.prototype.refresh = function() {
      var previousValue, value;
      this.cached = false;
      previousValue = this.value;
      value = this.getValue();
      if (value !== previousValue && !this.isIsolated()) {
        this.fire(value, previousValue);
      }
      if (this.value !== void 0 && this.isFinal()) {
        return this.lockValue();
      }
    };

    Property.prototype.sourceChangeHandler = function() {
      var _this = this;
      this._sourceChangeHandler || (this._sourceChangeHandler = this._handleSourceChange.bind(this));
      Batman.developer["do"](function() {
        return _this._sourceChangeHandler.property = _this;
      });
      return this._sourceChangeHandler;
    };

    Property.prototype._handleSourceChange = function() {
      if (this.isIsolated()) {
        return this._needsRefresh = true;
      } else if (!this.isFinal() && !this.hasObservers()) {
        return this.cached = false;
      } else {
        return this.refresh();
      }
    };

    Property.prototype.valueFromAccessor = function() {
      var _ref;
      return (_ref = this.accessor().get) != null ? _ref.call(this.base, this.key) : void 0;
    };

    Property.prototype.setValue = function(val) {
      var set;
      if (!(set = this.accessor().set)) {
        return;
      }
      return this._changeValue(function() {
        return set.call(this.base, this.key, val);
      });
    };

    Property.prototype.unsetValue = function() {
      var unset;
      if (!(unset = this.accessor().unset)) {
        return;
      }
      return this._changeValue(function() {
        return unset.call(this.base, this.key);
      });
    };

    Property.prototype._changeValue = function(block) {
      var result;
      this.cached = false;
      this.constructor.pushDummySourceTracker();
      try {
        result = block.apply(this);
        this.refresh();
      } finally {
        this.constructor.popSourceTracker();
      }
      if (!(this.isCached() || this.hasObservers())) {
        this.die();
      }
      return result;
    };

    Property.prototype.forget = function(handler) {
      if (handler != null) {
        return this.changeEvent().removeHandler(handler);
      } else {
        return this.changeEvent().clearHandlers();
      }
    };

    Property.prototype.observeAndFire = function(handler) {
      this.observe(handler);
      return handler.call(this.base, this.value, this.value, this.key);
    };

    Property.prototype.observe = function(handler) {
      this.changeEvent().addHandler(handler);
      if (this.sources == null) {
        this.getValue();
      }
      return this;
    };

    Property.prototype.observeOnce = function(originalHandler) {
      var event, handler;
      event = this.changeEvent();
      handler = function() {
        originalHandler.apply(this, arguments);
        return event.removeHandler(handler);
      };
      event.addHandler(handler);
      if (this.sources == null) {
        this.getValue();
      }
      return this;
    };

    Property.prototype._removeHandlers = function() {
      var handler, source, _i, _len, _ref;
      handler = this.sourceChangeHandler();
      if (this.sources) {
        _ref = this.sources;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          source = _ref[_i];
          source.event('change').removeHandler(handler);
        }
      }
      delete this.sources;
      return this.changeEvent().clearHandlers();
    };

    Property.prototype.lockValue = function() {
      this._removeHandlers();
      this.getValue = function() {
        return this.value;
      };
      return this.setValue = this.unsetValue = this.refresh = this.observe = function() {};
    };

    Property.prototype.die = function() {
      var _ref, _ref1;
      this._removeHandlers();
      if ((_ref = this.base._batman) != null) {
        if ((_ref1 = _ref.properties) != null) {
          _ref1.unset(this.key);
        }
      }
      return this.isDead = true;
    };

    Property.prototype.fire = function() {
      var _ref;
      return (_ref = this.changeEvent()).fire.apply(_ref, __slice.call(arguments).concat([this.key]));
    };

    Property.prototype.isolate = function() {
      if (this._isolationCount === 0) {
        this._preIsolationValue = this.getValue();
      }
      return this._isolationCount++;
    };

    Property.prototype.expose = function() {
      if (this._isolationCount === 1) {
        this._isolationCount--;
        if (this._needsRefresh) {
          this.value = this._preIsolationValue;
          this.refresh();
        } else if (this.value !== this._preIsolationValue) {
          this.fire(this.value, this._preIsolationValue);
        }
        return this._preIsolationValue = null;
      } else if (this._isolationCount > 0) {
        return this._isolationCount--;
      }
    };

    Property.prototype.isIsolated = function() {
      return this._isolationCount > 0;
    };

    return Property;

  })();

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Batman.Keypath = (function(_super) {

    __extends(Keypath, _super);

    function Keypath(base, key) {
      if (typeof key === 'string') {
        this.segments = key.split('.');
        this.depth = this.segments.length;
      } else {
        this.segments = [key];
        this.depth = 1;
      }
      Keypath.__super__.constructor.apply(this, arguments);
    }

    Keypath.prototype.isCachable = function() {
      if (this.depth === 1) {
        return Keypath.__super__.isCachable.apply(this, arguments);
      } else {
        return true;
      }
    };

    Keypath.prototype.terminalProperty = function() {
      var base;
      base = Batman.getPath(this.base, this.segments.slice(0, -1));
      if (base == null) {
        return;
      }
      return Batman.Keypath.forBaseAndKey(base, this.segments[this.depth - 1]);
    };

    Keypath.prototype.valueFromAccessor = function() {
      if (this.depth === 1) {
        return Keypath.__super__.valueFromAccessor.apply(this, arguments);
      } else {
        return Batman.getPath(this.base, this.segments);
      }
    };

    Keypath.prototype.setValue = function(val) {
      var _ref;
      if (this.depth === 1) {
        return Keypath.__super__.setValue.apply(this, arguments);
      } else {
        return (_ref = this.terminalProperty()) != null ? _ref.setValue(val) : void 0;
      }
    };

    Keypath.prototype.unsetValue = function() {
      var _ref;
      if (this.depth === 1) {
        return Keypath.__super__.unsetValue.apply(this, arguments);
      } else {
        return (_ref = this.terminalProperty()) != null ? _ref.unsetValue() : void 0;
      }
    };

    return Keypath;

  })(Batman.Property);

}).call(this);

(function() {
  var __slice = [].slice;

  Batman.Observable = {
    isObservable: true,
    hasProperty: function(key) {
      var _ref, _ref1;
      return (_ref = this._batman) != null ? (_ref1 = _ref.properties) != null ? typeof _ref1.hasKey === "function" ? _ref1.hasKey(key) : void 0 : void 0 : void 0;
    },
    property: function(key) {
      var properties, propertyClass, _base;
      Batman.initializeObject(this);
      propertyClass = this.propertyClass || Batman.Keypath;
      properties = (_base = this._batman).properties || (_base.properties = new Batman.SimpleHash);
      return properties.get(key) || properties.set(key, new propertyClass(this, key));
    },
    get: function(key) {
      return this.property(key).getValue();
    },
    set: function(key, val) {
      return this.property(key).setValue(val);
    },
    unset: function(key) {
      return this.property(key).unsetValue();
    },
    getOrSet: Batman.SimpleHash.prototype.getOrSet,
    forget: function(key, observer) {
      var _ref;
      if (key) {
        this.property(key).forget(observer);
      } else {
        if ((_ref = this._batman.properties) != null) {
          _ref.forEach(function(key, property) {
            return property.forget();
          });
        }
      }
      return this;
    },
    observe: function() {
      var args, key, _ref;
      key = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      (_ref = this.property(key)).observe.apply(_ref, args);
      return this;
    },
    observeAndFire: function() {
      var args, key, _ref;
      key = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      (_ref = this.property(key)).observeAndFire.apply(_ref, args);
      return this;
    },
    observeOnce: function() {
      var args, key, _ref;
      key = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      (_ref = this.property(key)).observeOnce.apply(_ref, args);
      return this;
    }
  };

}).call(this);

(function() {
  var BatmanObject, ObjectFunctions, getAccessorObject, promiseWrapper, wrapSingleAccessor,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  getAccessorObject = function(base, accessor) {
    var deprecated, _i, _len, _ref;
    if (typeof accessor === 'function') {
      accessor = {
        get: accessor
      };
    }
    _ref = ['cachable', 'cacheable'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      deprecated = _ref[_i];
      if (deprecated in accessor) {
        Batman.developer.warn("Property accessor option \"" + deprecated + "\" is deprecated. Use \"cache\" instead.");
        if (!('cache' in accessor)) {
          accessor.cache = accessor[deprecated];
        }
      }
    }
    return accessor;
  };

  promiseWrapper = function(fetcher) {
    return function(defaultAccessor) {
      return {
        get: function(key) {
          var asyncDeliver, existingValue, newValue, _base, _base1, _ref, _ref1,
            _this = this;
          if ((existingValue = defaultAccessor.get.apply(this, arguments)) != null) {
            return existingValue;
          }
          asyncDeliver = false;
          newValue = void 0;
          if ((_ref = (_base = this._batman).promises) == null) {
            _base.promises = {};
          }
          if ((_ref1 = (_base1 = this._batman.promises)[key]) == null) {
            _base1[key] = (function() {
              var deliver, returnValue;
              deliver = function(err, result) {
                if (asyncDeliver) {
                  _this.set(key, result);
                }
                return newValue = result;
              };
              returnValue = fetcher.call(_this, deliver, key);
              if (newValue == null) {
                newValue = returnValue;
              }
              return true;
            })();
          }
          asyncDeliver = true;
          return newValue;
        },
        cache: true
      };
    };
  };

  wrapSingleAccessor = function(core, wrapper) {
    var k, v;
    wrapper = (typeof wrapper === "function" ? wrapper(core) : void 0) || wrapper;
    for (k in core) {
      v = core[k];
      if (!(k in wrapper)) {
        wrapper[k] = v;
      }
    }
    return wrapper;
  };

  ObjectFunctions = {
    _defineAccessor: function() {
      var accessor, key, keys, _base, _i, _j, _len, _ref, _results;
      keys = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), accessor = arguments[_i++];
      if (!(accessor != null)) {
        return Batman.Property.defaultAccessorForBase(this);
      } else if (keys.length === 0 && ((_ref = Batman.typeOf(accessor)) !== 'Object' && _ref !== 'Function')) {
        return Batman.Property.accessorForBaseAndKey(this, accessor);
      } else if (typeof accessor.promise === 'function') {
        return this._defineWrapAccessor.apply(this, __slice.call(keys).concat([promiseWrapper(accessor.promise)]));
      }
      Batman.initializeObject(this);
      if (keys.length === 0) {
        return this._batman.defaultAccessor = getAccessorObject(this, accessor);
      } else {
        (_base = this._batman).keyAccessors || (_base.keyAccessors = new Batman.SimpleHash);
        _results = [];
        for (_j = 0, _len = keys.length; _j < _len; _j++) {
          key = keys[_j];
          _results.push(this._batman.keyAccessors.set(key, getAccessorObject(this, accessor)));
        }
        return _results;
      }
    },
    _defineWrapAccessor: function() {
      var key, keys, wrapper, _i, _j, _len, _results;
      keys = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), wrapper = arguments[_i++];
      Batman.initializeObject(this);
      if (keys.length === 0) {
        return this._defineAccessor(wrapSingleAccessor(this._defineAccessor(), wrapper));
      } else {
        _results = [];
        for (_j = 0, _len = keys.length; _j < _len; _j++) {
          key = keys[_j];
          _results.push(this._defineAccessor(key, wrapSingleAccessor(this._defineAccessor(key), wrapper)));
        }
        return _results;
      }
    },
    _resetPromises: function() {
      var key;
      if (this._batman.promises == null) {
        return;
      }
      for (key in this._batman.promises) {
        this._resetPromise(key);
      }
    },
    _resetPromise: function(key) {
      this.unset(key);
      this.property(key).cached = false;
      delete this._batman.promises[key];
    }
  };

  BatmanObject = (function(_super) {
    var counter;

    __extends(BatmanObject, _super);

    Batman.initializeObject(BatmanObject);

    Batman.initializeObject(BatmanObject.prototype);

    Batman.mixin(BatmanObject.prototype, ObjectFunctions, Batman.EventEmitter, Batman.Observable);

    Batman.mixin(BatmanObject, ObjectFunctions, Batman.EventEmitter, Batman.Observable);

    BatmanObject.classMixin = function() {
      return Batman.mixin.apply(Batman, [this].concat(__slice.call(arguments)));
    };

    BatmanObject.mixin = function() {
      return this.classMixin.apply(this.prototype, arguments);
    };

    BatmanObject.prototype.mixin = BatmanObject.classMixin;

    BatmanObject.classAccessor = BatmanObject._defineAccessor;

    BatmanObject.accessor = function() {
      var _ref;
      return (_ref = this.prototype)._defineAccessor.apply(_ref, arguments);
    };

    BatmanObject.prototype.accessor = BatmanObject._defineAccessor;

    BatmanObject.wrapClassAccessor = BatmanObject._defineWrapAccessor;

    BatmanObject.wrapAccessor = function() {
      var _ref;
      return (_ref = this.prototype)._defineWrapAccessor.apply(_ref, arguments);
    };

    BatmanObject.prototype.wrapAccessor = BatmanObject._defineWrapAccessor;

    BatmanObject.observeAll = function() {
      return this.prototype.observe.apply(this.prototype, arguments);
    };

    BatmanObject.singleton = function(singletonMethodName) {
      if (singletonMethodName == null) {
        singletonMethodName = "sharedInstance";
      }
      return this.classAccessor(singletonMethodName, {
        get: function() {
          var _name;
          return this[_name = "_" + singletonMethodName] || (this[_name] = new this);
        }
      });
    };

    BatmanObject.accessor('_batmanID', function() {
      return this._batmanID();
    });

    function BatmanObject() {
      var mixins;
      mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this._batman = new Batman._Batman(this);
      this.mixin.apply(this, mixins);
    }

    counter = 0;

    BatmanObject.prototype._batmanID = function() {
      var _base, _ref;
      this._batman.check(this);
      if ((_ref = (_base = this._batman).id) == null) {
        _base.id = counter++;
      }
      return this._batman.id;
    };

    BatmanObject.prototype.hashKey = function() {
      var _base;
      if (typeof this.isEqual === 'function') {
        return;
      }
      return (_base = this._batman).hashKey || (_base.hashKey = "<Batman.Object " + (this._batmanID()) + ">");
    };

    BatmanObject.prototype.toJSON = function() {
      var key, obj, value;
      obj = {};
      for (key in this) {
        if (!__hasProp.call(this, key)) continue;
        value = this[key];
        if (key !== "_batman" && key !== "hashKey" && key !== "_batmanID") {
          obj[key] = (value != null ? value.toJSON : void 0) ? value.toJSON() : value;
        }
      }
      return obj;
    };

    return BatmanObject;

  })(Object);

  Batman.Object = BatmanObject;

}).call(this);

(function() {
  var __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Batman.Inflector = (function() {

    Inflector.prototype.plural = function(regex, replacement) {
      return this._plural.unshift([regex, replacement]);
    };

    Inflector.prototype.singular = function(regex, replacement) {
      return this._singular.unshift([regex, replacement]);
    };

    Inflector.prototype.human = function(regex, replacement) {
      return this._human.unshift([regex, replacement]);
    };

    Inflector.prototype.uncountable = function() {
      var strings;
      strings = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this._uncountable = this._uncountable.concat(strings.map(function(x) {
        return new RegExp("" + x + "$", 'i');
      }));
    };

    Inflector.prototype.irregular = function(singular, plural) {
      if (singular.charAt(0) === plural.charAt(0)) {
        this.plural(new RegExp("(" + (singular.charAt(0)) + ")" + (singular.slice(1)) + "$", "i"), "$1" + plural.slice(1));
        this.plural(new RegExp("(" + (singular.charAt(0)) + ")" + (plural.slice(1)) + "$", "i"), "$1" + plural.slice(1));
        return this.singular(new RegExp("(" + (plural.charAt(0)) + ")" + (plural.slice(1)) + "$", "i"), "$1" + singular.slice(1));
      } else {
        this.plural(new RegExp("" + singular + "$", 'i'), plural);
        this.plural(new RegExp("" + plural + "$", 'i'), plural);
        return this.singular(new RegExp("" + plural + "$", 'i'), singular);
      }
    };

    function Inflector() {
      this._plural = [];
      this._singular = [];
      this._uncountable = [];
      this._human = [];
    }

    Inflector.prototype.ordinalize = function(number) {
      var absNumber, _ref;
      absNumber = Math.abs(parseInt(number));
      if (_ref = absNumber % 100, __indexOf.call([11, 12, 13], _ref) >= 0) {
        return number + "th";
      } else {
        switch (absNumber % 10) {
          case 1:
            return number + "st";
          case 2:
            return number + "nd";
          case 3:
            return number + "rd";
          default:
            return number + "th";
        }
      }
    };

    Inflector.prototype.pluralize = function(word) {
      var regex, replace_string, uncountableRegex, _i, _j, _len, _len1, _ref, _ref1, _ref2;
      _ref = this._uncountable;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        uncountableRegex = _ref[_i];
        if (uncountableRegex.test(word)) {
          return word;
        }
      }
      _ref1 = this._plural;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        _ref2 = _ref1[_j], regex = _ref2[0], replace_string = _ref2[1];
        if (regex.test(word)) {
          return word.replace(regex, replace_string);
        }
      }
      return word;
    };

    Inflector.prototype.singularize = function(word) {
      var regex, replace_string, uncountableRegex, _i, _j, _len, _len1, _ref, _ref1, _ref2;
      _ref = this._uncountable;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        uncountableRegex = _ref[_i];
        if (uncountableRegex.test(word)) {
          return word;
        }
      }
      _ref1 = this._singular;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        _ref2 = _ref1[_j], regex = _ref2[0], replace_string = _ref2[1];
        if (regex.test(word)) {
          return word.replace(regex, replace_string);
        }
      }
      return word;
    };

    Inflector.prototype.humanize = function(word) {
      var regex, replace_string, _i, _len, _ref, _ref1;
      _ref = this._human;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], regex = _ref1[0], replace_string = _ref1[1];
        if (regex.test(word)) {
          return word.replace(regex, replace_string);
        }
      }
      return word;
    };

    return Inflector;

  })();

}).call(this);

(function() {
  var Inflector, camelize_rx, capitalize_rx, humanize_rx1, humanize_rx2, humanize_rx3, underscore_rx1, underscore_rx2;

  camelize_rx = /(?:^|_|\-)(.)/g;

  capitalize_rx = /(^|\s)([a-z])/g;

  underscore_rx1 = /([A-Z]+)([A-Z][a-z])/g;

  underscore_rx2 = /([a-z\d])([A-Z])/g;

  humanize_rx1 = /_id$/;

  humanize_rx2 = /_|-/g;

  humanize_rx3 = /^\w/g;

  Batman.helpers = {
    ordinalize: function() {
      return Batman.helpers.inflector.ordinalize.apply(Batman.helpers.inflector, arguments);
    },
    singularize: function() {
      return Batman.helpers.inflector.singularize.apply(Batman.helpers.inflector, arguments);
    },
    pluralize: function(count, singular, plural, includeCount) {
      var result;
      if (includeCount == null) {
        includeCount = true;
      }
      if (arguments.length < 2) {
        return Batman.helpers.inflector.pluralize(count);
      } else {
        result = +count === 1 ? singular : plural || Batman.helpers.inflector.pluralize(singular);
        if (includeCount) {
          result = ("" + (count || 0) + " ") + result;
        }
        return result;
      }
    },
    camelize: function(string, firstLetterLower) {
      string = string.replace(camelize_rx, function(str, p1) {
        return p1.toUpperCase();
      });
      if (firstLetterLower) {
        return string.substr(0, 1).toLowerCase() + string.substr(1);
      } else {
        return string;
      }
    },
    underscore: function(string) {
      return string.replace(underscore_rx1, '$1_$2').replace(underscore_rx2, '$1_$2').replace('-', '_').toLowerCase();
    },
    capitalize: function(string) {
      return string.replace(capitalize_rx, function(m, p1, p2) {
        return p1 + p2.toUpperCase();
      });
    },
    trim: function(string) {
      if (string) {
        return string.trim();
      } else {
        return "";
      }
    },
    interpolate: function(stringOrObject, keys) {
      var key, string, value;
      if (typeof stringOrObject === 'object') {
        string = stringOrObject[keys.count];
        if (!string) {
          string = stringOrObject['other'];
        }
      } else {
        string = stringOrObject;
      }
      for (key in keys) {
        value = keys[key];
        string = string.replace(new RegExp("%\\{" + key + "\\}", "g"), value);
      }
      return string;
    },
    humanize: function(string) {
      string = Batman.helpers.underscore(string);
      string = Batman.helpers.inflector.humanize(string);
      return string.replace(humanize_rx1, '').replace(humanize_rx2, ' ').replace(humanize_rx3, function(match) {
        return match.toUpperCase();
      });
    }
  };

  Inflector = new Batman.Inflector;

  Batman.helpers.inflector = Inflector;

  Inflector.plural(/$/, 's');

  Inflector.plural(/s$/i, 's');

  Inflector.plural(/(ax|test)is$/i, '$1es');

  Inflector.plural(/(octop|vir)us$/i, '$1i');

  Inflector.plural(/(octop|vir)i$/i, '$1i');

  Inflector.plural(/(alias|status)$/i, '$1es');

  Inflector.plural(/(bu)s$/i, '$1ses');

  Inflector.plural(/(buffal|tomat)o$/i, '$1oes');

  Inflector.plural(/([ti])um$/i, '$1a');

  Inflector.plural(/([ti])a$/i, '$1a');

  Inflector.plural(/sis$/i, 'ses');

  Inflector.plural(/(?:([^f])fe|([lr])f)$/i, '$1$2ves');

  Inflector.plural(/(hive)$/i, '$1s');

  Inflector.plural(/([^aeiouy]|qu)y$/i, '$1ies');

  Inflector.plural(/(x|ch|ss|sh)$/i, '$1es');

  Inflector.plural(/(matr|vert|ind)(?:ix|ex)$/i, '$1ices');

  Inflector.plural(/([m|l])ouse$/i, '$1ice');

  Inflector.plural(/([m|l])ice$/i, '$1ice');

  Inflector.plural(/^(ox)$/i, '$1en');

  Inflector.plural(/^(oxen)$/i, '$1');

  Inflector.plural(/(quiz)$/i, '$1zes');

  Inflector.singular(/s$/i, '');

  Inflector.singular(/(n)ews$/i, '$1ews');

  Inflector.singular(/([ti])a$/i, '$1um');

  Inflector.singular(/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, '$1$2sis');

  Inflector.singular(/(^analy)ses$/i, '$1sis');

  Inflector.singular(/([^f])ves$/i, '$1fe');

  Inflector.singular(/(hive)s$/i, '$1');

  Inflector.singular(/(tive)s$/i, '$1');

  Inflector.singular(/([lr])ves$/i, '$1f');

  Inflector.singular(/([^aeiouy]|qu)ies$/i, '$1y');

  Inflector.singular(/(s)eries$/i, '$1eries');

  Inflector.singular(/(m)ovies$/i, '$1ovie');

  Inflector.singular(/(x|ch|ss|sh)es$/i, '$1');

  Inflector.singular(/([m|l])ice$/i, '$1ouse');

  Inflector.singular(/(bus)es$/i, '$1');

  Inflector.singular(/(o)es$/i, '$1');

  Inflector.singular(/(shoe)s$/i, '$1');

  Inflector.singular(/(cris|ax|test)es$/i, '$1is');

  Inflector.singular(/(octop|vir)i$/i, '$1us');

  Inflector.singular(/(alias|status)es$/i, '$1');

  Inflector.singular(/^(ox)en/i, '$1');

  Inflector.singular(/(vert|ind)ices$/i, '$1ex');

  Inflector.singular(/(matr)ices$/i, '$1ix');

  Inflector.singular(/(quiz)zes$/i, '$1');

  Inflector.singular(/(database)s$/i, '$1');

  Inflector.irregular('person', 'people');

  Inflector.irregular('man', 'men');

  Inflector.irregular('child', 'children');

  Inflector.irregular('sex', 'sexes');

  Inflector.irregular('move', 'moves');

  Inflector.irregular('cow', 'kine');

  Inflector.irregular('zombie', 'zombies');

  Inflector.uncountable('equipment', 'information', 'rice', 'money', 'species', 'series', 'fish', 'sheep', 'jeans');

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Batman.StateMachine = (function(_super) {

    __extends(StateMachine, _super);

    StateMachine.InvalidTransitionError = function(message) {
      this.message = message != null ? message : "";
    };

    StateMachine.InvalidTransitionError.prototype = new Error;

    StateMachine.transitions = function(table) {
      var definePredicate, fromState, k, object, predicateKeys, toState, transitions, v, _fn, _ref,
        _this = this;
      for (k in table) {
        v = table[k];
        if (!(v.from && v.to)) {
          continue;
        }
        object = {};
        if (v.from.forEach) {
          v.from.forEach(function(fromKey) {
            return object[fromKey] = v.to;
          });
        } else {
          object[v.from] = v.to;
        }
        table[k] = object;
      }
      this.prototype.transitionTable = Batman.extend({}, this.prototype.transitionTable, table);
      predicateKeys = [];
      definePredicate = function(state) {
        var key;
        key = "is" + (Batman.helpers.capitalize(state));
        if (_this.prototype[key] != null) {
          return;
        }
        predicateKeys.push(key);
        return _this.prototype[key] = function() {
          return this.get('state') === state;
        };
      };
      _ref = this.prototype.transitionTable;
      _fn = function(k) {
        return _this.prototype[k] = function() {
          return this.startTransition(k);
        };
      };
      for (k in _ref) {
        transitions = _ref[k];
        if (!(!this.prototype[k])) {
          continue;
        }
        _fn(k);
        for (fromState in transitions) {
          toState = transitions[fromState];
          definePredicate(fromState);
          definePredicate(toState);
        }
      }
      if (predicateKeys.length) {
        this.accessor.apply(this, __slice.call(predicateKeys).concat([function(key) {
          return this[key]();
        }]));
      }
      return this;
    };

    function StateMachine(startState) {
      this.nextEvents = [];
      this.set('_state', startState);
    }

    StateMachine.accessor('state', function() {
      return this.get('_state');
    });

    StateMachine.prototype.isTransitioning = false;

    StateMachine.prototype.transitionTable = {};

    StateMachine.prototype.onTransition = function(from, into, callback) {
      return this.on("" + from + "->" + into, callback);
    };

    StateMachine.prototype.onEnter = function(into, callback) {
      return this.on("enter " + into, callback);
    };

    StateMachine.prototype.onExit = function(from, callback) {
      return this.on("exit " + from, callback);
    };

    StateMachine.prototype.startTransition = Batman.Property.wrapTrackingPrevention(function(event) {
      var nextState, previousState;
      if (this.isTransitioning) {
        this.nextEvents.push(event);
        return;
      }
      previousState = this.get('state');
      nextState = this.nextStateForEvent(event);
      if (!nextState) {
        return false;
      }
      this.isTransitioning = true;
      this.fire("exit " + previousState);
      this.set('_state', nextState);
      this.fire("" + previousState + "->" + nextState);
      this.fire("enter " + nextState);
      this.fire(event);
      this.isTransitioning = false;
      if (this.nextEvents.length > 0) {
        this.startTransition(this.nextEvents.shift());
      }
      return true;
    });

    StateMachine.prototype.canStartTransition = function(event, fromState) {
      if (fromState == null) {
        fromState = this.get('state');
      }
      return !!this.nextStateForEvent(event, fromState);
    };

    StateMachine.prototype.nextStateForEvent = function(event, fromState) {
      var _ref;
      if (fromState == null) {
        fromState = this.get('state');
      }
      return (_ref = this.transitionTable[event]) != null ? _ref[fromState] : void 0;
    };

    return StateMachine;

  })(Batman.Object);

  Batman.DelegatingStateMachine = (function(_super) {

    __extends(DelegatingStateMachine, _super);

    function DelegatingStateMachine(startState, base) {
      this.base = base;
      DelegatingStateMachine.__super__.constructor.call(this, startState);
    }

    DelegatingStateMachine.prototype.fire = function() {
      var result, _ref;
      result = DelegatingStateMachine.__super__.fire.apply(this, arguments);
      (_ref = this.base).fire.apply(_ref, arguments);
      return result;
    };

    return DelegatingStateMachine;

  })(Batman.StateMachine);

}).call(this);

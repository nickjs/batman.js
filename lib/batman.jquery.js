(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Batman.extend(Batman.DOM, {
    querySelectorAll: function(node, selector) {
      return jQuery(selector, node);
    },
    querySelector: function(node, selector) {
      return jQuery(selector, node)[0];
    },
    setInnerHTML: function(node, html) {
      return jQuery(node).html(html);
    },
    destroyNode: function(node) {
      Batman.DOM.cleanupNode(node);
      jQuery(node).remove();
    },
    textContent: function(node) {
      return jQuery(node).text();
    },
    addEventListener: function(node, eventName, callback) {
      return $(node).on(eventName, callback);
    },
    removeEventListener: function(node, eventName, callback) {
      return $(node).off(eventName, callback);
    }
  });
  Batman.View.accessor('$node', function() {
    if (this.get('node')) {
      return $(this.node);
    }
  });
  Batman.Request.prototype._parseResponseHeaders = function(xhr) {
    var headers;
    return headers = xhr.getAllResponseHeaders().split('\n').reduce(function(acc, header) {
      var key, matches, value;
      if (matches = header.match(/([^:]*):\s*(.*)/)) {
        key = matches[1];
        value = matches[2];
        acc[key] = value;
      }
      return acc;
    }, {});
  };
  Batman.Request.prototype._prepareOptions = function(data) {
    var options, _ref;
    options = {
      url: this.get('url'),
      type: this.get('method'),
      dataType: this.get('type'),
      data: data || this.get('data'),
      username: this.get('username'),
      password: this.get('password'),
      headers: this.get('headers'),
      beforeSend: __bind(function() {
        return this.fire('loading');
      }, this),
      success: __bind(function(response, textStatus, xhr) {
        this.mixin({
          xhr: xhr,
          status: xhr.status,
          response: response,
          responseHeaders: this._parseResponseHeaders(xhr)
        });
        return this.fire('success', response);
      }, this),
      error: __bind(function(xhr, status, error) {
        this.mixin({
          xhr: xhr,
          status: xhr.status,
          response: xhr.responseText,
          responseHeaders: this._parseResponseHeaders(xhr)
        });
        xhr.request = this;
        return this.fire('error', xhr);
      }, this),
      complete: __bind(function() {
        return this.fire('loaded');
      }, this)
    };
    if ((_ref = this.get('method')) === 'PUT' || _ref === 'POST') {
      if (!this.hasFileUploads()) {
        options.contentType = this.get('contentType');
        if (typeof options.data === 'object') {
          options.processData = false;
          options.data = Batman.URI.queryFromParams(options.data);
        }
      } else {
        options.contentType = false;
        options.processData = false;
        options.data = this.constructor.objectToFormData(options.data);
      }
    }
    return options;
  };
  Batman.Request.prototype.send = function(data) {
    return jQuery.ajax(this._prepareOptions(data));
  };
}).call(this);

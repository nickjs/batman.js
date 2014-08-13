/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "dist/";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

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
	  containsNode: function(parent, child) {
	    if (!child) {
	      child = parent;
	      parent = document.body;
	    }
	    return $.contains(parent, child);
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

	Batman.extend(Batman.Request.prototype, {
	  _parseResponseHeaders: function(xhr) {
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
	  },
	  _prepareOptions: function(data) {
	    var options, _ref;
	    options = {
	      url: this.get('url'),
	      type: this.get('method'),
	      dataType: this.get('type'),
	      data: data || this.get('data'),
	      username: this.get('username'),
	      password: this.get('password'),
	      headers: this.get('headers'),
	      beforeSend: (function(_this) {
	        return function() {
	          return _this.fire('loading');
	        };
	      })(this),
	      success: (function(_this) {
	        return function(response, textStatus, xhr) {
	          _this.mixin({
	            xhr: xhr,
	            status: xhr.status,
	            response: response,
	            responseHeaders: _this._parseResponseHeaders(xhr)
	          });
	          return _this.fire('success', response);
	        };
	      })(this),
	      error: (function(_this) {
	        return function(xhr, status, error) {
	          _this.mixin({
	            xhr: xhr,
	            status: xhr.status,
	            response: xhr.responseText,
	            responseHeaders: _this._parseResponseHeaders(xhr)
	          });
	          xhr.request = _this;
	          return _this.fire('error', xhr);
	        };
	      })(this),
	      complete: (function(_this) {
	        return function() {
	          return _this.fire('loaded');
	        };
	      })(this)
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
	  },
	  send: function(data) {
	    return jQuery.ajax(this._prepareOptions(data));
	  }
	});


/***/ }
/******/ ])
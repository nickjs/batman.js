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

	var RailsModelMixin, date_re, numericKeys,
	  __slice = [].slice,
	  __hasProp = {}.hasOwnProperty,
	  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

	Batman.config.pathToHTML = '/assets/batman/html';

	Batman.config.protectFromCSRF = true;

	Batman.config.metaNameForCSRFToken = 'csrf-token';

	numericKeys = [1, 2, 3, 4, 5, 6, 7, 10, 11];

	date_re = /^(\d{4}|[+\-]\d{6})(?:-(\d{2})(?:-(\d{2}))?)?(?:T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{3}))?)?(?:(Z)|([+\-])(\d{2})(?::(\d{2}))?)?)?$/;

	Batman.Encoders.railsDate = {
	  encode: function(value) {
	    return value;
	  },
	  decode: function(value) {
	    var key, minutesOffset, obj, _i, _len;
	    if (value != null) {
	      if ((obj = date_re.exec(value))) {
	        for (_i = 0, _len = numericKeys.length; _i < _len; _i++) {
	          key = numericKeys[_i];
	          obj[key] = +obj[key] || 0;
	        }
	        obj[2] = (+obj[2] || 1) - 1;
	        obj[3] = +obj[3] || 1;
	        if (obj[8] !== "Z" && obj[9] !== void 0) {
	          minutesOffset = obj[10] * 60 + obj[11];
	          if (obj[9] === "+") {
	            minutesOffset = 0 - minutesOffset;
	          }
	        } else {
	          minutesOffset = new Date(obj[1], obj[2], obj[3], obj[4], obj[5], obj[6], obj[7]).getTimezoneOffset();
	        }
	        return new Date(Date.UTC(obj[1], obj[2], obj[3], obj[4], obj[5] + minutesOffset, obj[6], obj[7]));
	      } else {
	        Batman.developer.warn("Unrecognized rails date " + value + "!");
	        return Date.parse(value);
	      }
	    }
	  }
	};

	RailsModelMixin = {
	  encodeTimestamps: function() {
	    var attrs;
	    attrs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
	    if (attrs.length === 0) {
	      attrs = ['created_at', 'updated_at'];
	    }
	    return this.encode.apply(this, __slice.call(attrs).concat([{
	      encode: false,
	      decode: Batman.Encoders.railsDate.decode
	    }]));
	  },
	  _encodesNestedAttributesForKeys: [],
	  encodesNestedAttributesFor: function() {
	    var keys;
	    keys = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
	    return this._encodesNestedAttributesForKeys = this._encodesNestedAttributesForKeys.concat(keys);
	  }
	};

	Batman.Model.encodeTimestamps = function() {
	  Batman.developer.warn("You must use Batman.RailsStorage to use encodeTimestamps. Use it with `@persist(Batman.RailsStorage)` in your model definition.");
	  return RailsModelMixin.encodeTimestamps.apply(this, arguments);
	};

	Batman.RailsStorage = (function(_super) {
	  __extends(RailsStorage, _super);

	  function RailsStorage() {
	    return RailsStorage.__super__.constructor.apply(this, arguments);
	  }

	  RailsStorage.ModelMixin = Batman.mixin({}, Batman.RestStorage.ModelMixin, RailsModelMixin);

	  RailsStorage.prototype.urlForRecord = function() {
	    return this._addJsonExtension(RailsStorage.__super__.urlForRecord.apply(this, arguments));
	  };

	  RailsStorage.prototype.urlForCollection = function() {
	    return this._addJsonExtension(RailsStorage.__super__.urlForCollection.apply(this, arguments));
	  };

	  RailsStorage.prototype._addJsonExtension = function(url) {
	    if (url.indexOf('?') !== -1 || url.substr(-5, 5) === '.json') {
	      return url;
	    }
	    return url + '.json';
	  };

	  RailsStorage.prototype._errorsFrom422Response = function(response) {
	    var parsedResponse;
	    parsedResponse = JSON.parse(response);
	    if ('errors' in parsedResponse) {
	      return parsedResponse.errors;
	    } else {
	      return parsedResponse;
	    }
	  };

	  RailsStorage.prototype.before('all', function(env, next) {
	    var headers, tag, token, _base;
	    if (!Batman.config.protectFromCSRF) {
	      return next();
	    }
	    if (Batman.config.CSRF_TOKEN == null) {
	      if (tag = Batman.DOM.querySelector(document.head, "meta[name=\"" + Batman.config.metaNameForCSRFToken + "\"]")) {
	        Batman.config.CSRF_TOKEN = tag.getAttribute('content');
	      } else {
	        Batman.config.CSRF_TOKEN = null;
	      }
	    }
	    if (token = Batman.config.CSRF_TOKEN) {
	      headers = (_base = env.options).headers || (_base.headers = {});
	      if (headers['X-CSRF-Token'] == null) {
	        headers['X-CSRF-Token'] = token;
	      }
	    }
	    return next();
	  });

	  RailsStorage.prototype.after('update', 'create', function(env, next) {
	    var error, errorsArray, extractionError, key, record, response, validationError, validationErrors, _i, _len;
	    record = env.subject;
	    error = env.error, response = env.response;
	    if (error) {
	      if (error instanceof Batman.StorageAdapter.UnprocessableRecordError) {
	        try {
	          validationErrors = this._errorsFrom422Response(response);
	        } catch (_error) {
	          extractionError = _error;
	          env.error = extractionError;
	          return next();
	        }
	        for (key in validationErrors) {
	          errorsArray = validationErrors[key];
	          for (_i = 0, _len = errorsArray.length; _i < _len; _i++) {
	            validationError = errorsArray[_i];
	            record.get('errors').add(key, validationError);
	          }
	        }
	        env.result = record;
	        env.error = record.get('errors');
	        return next();
	      }
	    }
	    return next();
	  });

	  RailsStorage.prototype.before('create', 'update', function(env, next) {
	    var attrs, data, key, namespace, nestedAttributeKeys, recordJSON, _i, _len;
	    nestedAttributeKeys = env.subject.constructor._encodesNestedAttributesForKeys;
	    if (!nestedAttributeKeys.length) {
	      return next();
	    }
	    if (this.serializeAsForm) {
	      data = env.options.data;
	    } else {
	      data = JSON.parse(env.options.data);
	    }
	    if (namespace = this.recordJsonNamespace(env.subject)) {
	      recordJSON = data[namespace];
	    } else {
	      recordJSON = data;
	    }
	    for (_i = 0, _len = nestedAttributeKeys.length; _i < _len; _i++) {
	      key = nestedAttributeKeys[_i];
	      if (recordJSON[key] != null) {
	        attrs = recordJSON["" + key + "_attributes"] = recordJSON[key];
	        delete recordJSON[key];
	      }
	    }
	    if (!this.serializeAsForm) {
	      env.options.data = JSON.stringify(data);
	    }
	    return next();
	  });

	  RailsStorage.prototype.after('update', RailsStorage.skipIfError(function(env, next) {
	    var associatedRecord, association, associationSet, key, _i, _len, _ref;
	    _ref = env.subject.constructor._encodesNestedAttributesForKeys;
	    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
	      key = _ref[_i];
	      association = env.subject.reflectOnAssociation(key);
	      if (association == null) {
	        Batman.developer.error("No assocation was found for nested attribute " + key);
	      } else if (association instanceof Batman.PluralAssociation) {
	        associationSet = env.subject.get(key);
	        associationSet.forEach(function(object) {
	          if (object.get('_destroy')) {
	            associationSet.remove(object);
	            return object.constructor.get('loaded').remove(object);
	          }
	        });
	      } else if (association instanceof Batman.SingularAssociation && env.subject.get("" + key + "._destroy")) {
	        associatedRecord = env.subject.get(key);
	        if (associatedRecord.isProxy) {
	          associatedRecord = associatedRecord.get('target');
	        }
	        env.subject._withoutDirtyTracking(function() {
	          return this.set(key, null);
	        });
	        association.getRelatedModel().get('loaded').remove(associatedRecord);
	      }
	    }
	    return next();
	  }));

	  return RailsStorage;

	})(Batman.RestStorage);


/***/ }
/******/ ])
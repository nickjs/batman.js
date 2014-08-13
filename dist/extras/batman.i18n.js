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

	Batman.I18N = __webpack_require__(4);


/***/ },
/* 1 */,
/* 2 */,
/* 3 */,
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	var I18N, setupFilters,
	  __hasProp = {}.hasOwnProperty,
	  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

	setupFilters = function() {
	  Batman.Filters.t = Batman.Filters.translate = function(string, interpolationKeypaths, binding) {
	    var translated;
	    if (!binding) {
	      binding = interpolationKeypaths;
	      interpolationKeypaths = void 0;
	    }
	    if (string == null) {
	      return "";
	    }
	    if (!(binding.key && binding.key.substr(0, 2) === "t.")) {
	      translated = Batman.I18N.translate(string);
	      if (translated) {
	        string = translated;
	      }
	    }
	    return Batman.Filters.interpolate.call(this, string, interpolationKeypaths, binding);
	  };
	  return Batman.config.translations = true;
	};

	I18N = (function(_super) {
	  __extends(I18N, _super);

	  I18N.defaultLocale = "en";

	  I18N.useFallback = false;

	  I18N.classAccessor('locale', {
	    get: function() {
	      return this.locale || this.get('defaultLocale');
	    },
	    set: function(k, v) {
	      return this.locale = v;
	    },
	    unset: function() {
	      var x;
	      x = this.locale;
	      delete this.locale;
	      return x;
	    }
	  });

	  I18N.classAccessor('translations', function() {
	    return this.get("locales." + (this.get('locale')));
	  });

	  I18N.classAccessor('defaultTranslations', function() {
	    return this.get("locales." + this.defaultLocale);
	  });

	  I18N.translate = function(key, values) {
	    var translation;
	    translation = this.get("translations." + key);
	    if (this.useFallback) {
	      translation || (translation = this.get("defaultTranslations." + key));
	    }
	    if (translation == null) {
	      Batman.developer.warn("Warning, undefined translation " + key + " when in locale " + (this.get('locale')));
	      return "";
	    }
	    if (!values) {
	      return translation;
	    }
	    return Batman.helpers.interpolate(translation, values);
	  };

	  I18N.enable = function() {
	    setupFilters();
	    this._oldTranslation || (this._oldTranslation = Batman.translate);
	    this._newTranslate || (this._newTranslate = (function(_this) {
	      return function() {
	        return _this.translate.apply(_this, arguments);
	      };
	    })(this));
	    if (Batman.translate !== this._newTranslate) {
	      this.get('locales').set('en', Batman.translate.messages);
	      return Batman.translate = this._newTranslate;
	    }
	  };

	  I18N.disable = function() {
	    if (this._oldTranslation != null) {
	      return Batman.translate = this._oldTranslation;
	    }
	  };

	  function I18N() {
	    Batman.developer.error("Can't instantiate i18n!");
	  }

	  return I18N;

	})(Batman.Object);

	I18N.LocalesStorage = (function(_super) {
	  __extends(LocalesStorage, _super);

	  function LocalesStorage() {
	    this.isStorage = true;
	    this._storage = {};
	    LocalesStorage.__super__.constructor.apply(this, arguments);
	  }

	  LocalesStorage.accessor({
	    get: function(k) {
	      if (!this._storage[k]) {
	        this._storage[k] = {};
	        new Batman.Request({
	          url: "/locales/" + k + ".json",
	          success: (function(_this) {
	            return function(data) {
	              return _this.set(k, data[k]);
	            };
	          })(this),
	          error: function(xhr) {
	            return Batman.developer.warn("Couldn't load locale file " + k + "!");
	          }
	        });
	      }
	      return this._storage[k];
	    },
	    set: function(k, v) {
	      return this._storage[k] = v;
	    },
	    unset: function(k) {
	      var x;
	      x = this._storage[k];
	      delete this._storage[k];
	      return x;
	    }
	  });

	  return LocalesStorage;

	})(Batman.Object);

	I18N.set('locales', new I18N.LocalesStorage);

	module.exports = I18N;


/***/ }
/******/ ])
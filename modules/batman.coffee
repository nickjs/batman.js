Foundation = require 'foundation'
Utilities = require 'utilities'
ModelLayer = require 'model_layer'
ControllerLayer = require 'controller_layer'
ViewLayer = require 'view_layer'
AppLayer = require 'app_layer'

Batman = ->
  new Foundation.BatmanObject(arguments...)

Foundation.mixin(
  Batman,
  Foundation,
  Utilities,
  {
    Object: Foundation.BatmanObject
    Event: Foundation.BatmanEvent
  }
  ModelLayer,
  ModelLayer.Translate,
  ControllerLayer,
  ViewLayer,
  AppLayer,
)

Batman.redirect = (url, replaceState=false) ->
  Batman.navigator?.redirect(url, replaceState)

(Batman.container = do -> this).Batman = Batman  # I am so, so sorry.

Batman.developer.addFilters()

# Support AMD loaders
if typeof define is 'function'
  define 'batman', [], -> Batman

Batman.container.$context ?= (node) ->
  while node
    return view if view = (Batman._data(node, 'backingView') || Batman._data(node, 'view'))
    node = node.parentNode

Batman.container.$subviews ?= (view = Batman.currentApp.layout) ->
  subviews = []

  view.subviews.forEach (subview) ->
    obj = Batman.mixin({}, subview)
    obj.constructor = subview.constructor
    obj.subviews = if subview.subviews?.length then $subviews(subview) else null
    Batman.unmixin(obj, {'_batman': true})
    subviews.push(obj)
  subviews

Batman.config =
  pathToApp: '/'
  usePushState: true

  pathToHTML: 'html'
  fetchRemoteHTML: true
  cacheViews: false

  minificationErrors: true
  protectFromCSRF: false

# Solo adapter and dependencies:
window.zest = require("../polyfills/zest.js")
window.reqwest = require("../polyfills/reqwest.js")
require("script!../polyfills/contains.coffee")
require("script!../platform/solo.coffee")

module.exports = Batman

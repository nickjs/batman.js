{BatmanObject} = require 'foundation'

module.exports = class Yield extends BatmanObject
  @yields: {}

  @reset: -> @yields = {}

  @withName: (name) ->
    @yields[name] ||= new this(name)

  constructor: (@name) ->

  @accessor 'contentView',
    get: -> @contentView
    set: (key, view) ->
      return if @contentView == view

      if @contentView
        @contentView.removeFromSuperview()

      @contentView = view

      if @containerNode and view
        view.set('parentNode', @containerNode)

  @accessor 'containerNode',
    get: -> @containerNode
    set: (key, node) ->
      return if @containerNode == node

      @containerNode = node

      if @contentView
        @contentView.set('parentNode', node)

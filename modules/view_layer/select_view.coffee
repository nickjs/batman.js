BackingView = require './backing_view'

module.exports = class SelectView extends BackingView
  _addChildBinding: (binding) ->
    super
    @fire('childBindingAdded', binding)

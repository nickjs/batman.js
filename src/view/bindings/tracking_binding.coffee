#= require ./abstract_attribute_binding

Batman.Tracking =
  loadTracker: ->
    return Batman.Tracking.tracker if Batman.Tracking.tracker

    Batman.Tracking.tracker = if Batman.currentApp.EventTracker
      new Batman.currentApp.EventTracker
    else
      Batman.developer.warn "Define #{Batman.currentApp.name}.EventTracker to use data-track"
      {track: ->}

    return Batman.Tracking.tracker

  trackEvent: (type, data, node) ->
    Batman.Tracking.loadTracker().track(type, data, node)

class Batman.DOM.ClickTrackingBinding extends Batman.DOM.AbstractAttributeBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.None
  bindImmediately: false

  constructor: ->
    super

    callback = => Batman.Tracking.trackEvent('click', @get('filteredValue'), @node)
    Batman.DOM.events.click(@node, callback, @view, 'click', false)

    @bind()

class Batman.DOM.ViewTrackingBinding extends Batman.DOM.AbstractAttributeBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.None

  constructor: ->
    super
    Batman.Tracking.trackEvent('view', @get('filteredValue'), @node)

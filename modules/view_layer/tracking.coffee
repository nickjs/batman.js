module.exports = Tracking =
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
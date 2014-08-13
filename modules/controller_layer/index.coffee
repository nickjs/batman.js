ControllerLayer = {
  Controller: require './controller'
  ControllerActionFrame: require './controller_action_frame'
  RenderCache: require './render_cache'
}

Routing = require './routing'
for k, v of Routing
  ControllerLayer[k] = v

module.exports = ControllerLayer

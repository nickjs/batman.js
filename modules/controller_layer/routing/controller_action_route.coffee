Route = require './route'

module.exports = class ControllerActionRoute extends Route
  optionKeys: ['member', 'collection', 'app', 'controller', 'action']
  constructor: (templatePath, options) ->
    if options.signature
      if Batman.typeOf(options.signature) is 'String'
        [controller, action] = options.signature.split('#')
      else
        {controller, action} = options.signature

      action ||= 'index'
      options.controller = controller
      options.action = action
      delete options.signature

    super(templatePath, options)

  callback: (params) =>
    controllerShortName = @get('controller')
    controller = @get("app.dispatcher.controllers.#{controllerShortName}")
    if !controller?
      throw new Error("Couldn't find #{Batman.helpers.titleize(controllerShortName)}Controller when dispatching #{controllerShortName}##{@get('action')}!")
    else
      controller.dispatch(@get('action'), params)

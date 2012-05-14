#= require ./route
class Batman.ControllerActionRoute extends Batman.Route
  optionKeys: ['member', 'collection', 'app', 'controller', 'action']
  constructor: (templatePath, options) ->
    if options.signature
      [controller, action] = options.signature.split('#')
      action ||= 'index'
      options.controller = controller
      options.action = action
      delete options.signature

    super(templatePath, options)

  callback: (params) =>
    controller = @get("app.dispatcher.controllers.#{@get('controller')}")
    controller.dispatch(@get('action'), params)

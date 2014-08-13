Routing = {
  CallbackActionRoute:        require './callback_action_route'
  ControllerActionRoute:      require './controller_action_route'
  Dispatcher:                 require './dispatcher'
  HashbangNavigator:          require './hash_bang_navigator'
  NamedRouteQuery:            require './named_route_query'
  Navigator:                  require './navigator'
  Params:                     require './params'
  ParamsPusher:               require './params_pusher'
  ParamsReplacer:             require './params_replacer'
  PushStateNavigator:         require './push_state_navigator'
  Route:                      require './route'
  RouteMap:                   require './route_map'
  RouteMapBuilder:            require './route_map_builder'
  UrlParams:                  require './url_params'
}

module.exports = Routing
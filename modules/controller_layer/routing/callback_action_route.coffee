Route = require './route'

module.exports = class CallbackActionRoute extends Route
  optionKeys: ['member', 'collection', 'callback', 'app']
  controller: false
  action: false

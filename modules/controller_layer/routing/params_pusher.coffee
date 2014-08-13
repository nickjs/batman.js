ParamsReplacer = require './params_replacer'

module.exports = class ParamsPusher extends ParamsReplacer
  redirect: -> @navigator.redirect(@toObject())

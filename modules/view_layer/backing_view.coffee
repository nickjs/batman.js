View = require './view'
module.exports = class BackingView extends View
  isBackingView: true
  bindImmediately: false
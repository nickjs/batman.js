Batman = require '../../../../lib/dist/batman.node'

module.exports = class Clunk extends Batman.Object
  constructor: ->
    @foo = 'bar'
    @bar = {foo: 'bar'}
    @baz = 32412312312
    @qux = {}
    super

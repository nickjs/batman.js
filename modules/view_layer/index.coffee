# TO DO: how to handle references to DOM.events in binding code?
DOM = require './dom/dom'

DOM.events = require './dom/events'
DOM.Yield = require './dom/yield'
DOM.readers = require './dom/readers'
DOM.attrReaders = require './dom/attribute_readers'
DOM.AttrReaderBindingDefinition = require './dom/attribute_reader_binding_definition'
DOM.ReaderBindingDefinition = require './dom/reader_binding_definition'

Bindings = require './bindings'
for own k, v of Bindings
  DOM[k] = v

ViewLayer = {
  BindingParser:  require './binding_parser'
  DOM
  Filters:        require './filters'
  View:           require './view'
  BackingView:    require './backing_view'
  SelectView:     require './select_view'
  IterationView:  require './iteration_view'
  IteratorView:   require './iterator_view'
  HTMLStore:      require './html_store'
  Tracking:       require './tracking'
}

Data = require './data'
DOMHelpers = require './dom/dom_helpers'

mixins = [Data, DOMHelpers]

for mixin in mixins
  for own k, v of mixin
    ViewLayer[k] = v

module.exports = ViewLayer
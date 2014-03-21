# /api/App Internals/Batman.BackingView

`Batman.BackingView` is instantiated by some bindings to keep track of nodes and data.

## ::.isBackingView[=true]
## ::.bindImmediately[=false]

# /api/App Internals/Batman.BackingView/Batman.SelectView

`Batman.SelectView` is the backing view for a `Batman.DOM.SelectBinding`. It fires `childBindingAdded` whenever a new child binding is added. (This event is observed by the select binding.)

# /api/App Internals/Bindings

Batman.js bindings are created when a `Batman.View` passes itself to the `Batman.BindingParser` constructor. When initialized, the `Batman.BindingParser` pulls out `data-` attributes from the view's HTML and uses them to instantiate new bindings.

# /api/App Internals/Bindings/Batman.DOM.AbstractBinding

Extended by:
- `Batman.DOM.AbstractAttributeBinidng`
- `DebuggerBinding`
- `Batman.DOM.AbstractCollectionBinding`
- `Batman.DOM.DeferredRenderBinding`
- `Batman.DOM.FileBinding`
- `Batman.DOM.InsertionBinding`
- `Batman.DOM.RadioBinding`
- `Batman.DOM.RouteBinding`
- `Batman.DOM.SelectBinding`
- `Batman.DOM.ShowHideBinding`
- `Batman.DOM.ValueBinding`
- `Batman.DOM.ViewBinding`
- `Batman.DOM.ViewArgumentBinding`

## ::%unfilteredValue
## ::.bindImmediately[=true]
## ::.shouldSet[=true ]
## ::.isInputBinding[=false]
## ::.onlyObserve[='all']
## ::.skipParseFilter[=false]

## ::constructor(definition: Object) : AbstractBinding
## ::isTwoWay() : Boolean
## ::bind()
## ::die()
## ::parseFilter()
## ::parseSegment(segment: String)
## ::setupBackingView(viewClass, viewOptions) : View

# /api/App Internals/Bindings/Batman.DOM.AbstractAttributeBinding

Extended by:
- `Batman.DOM.AttributeBinidng`
- `Batman.DOM.ContextBinding`
- `Batman.DOM.ClickTrackingBinding`
- `Batman.DOM.ViewTrackingBinding`

## ::constructor: (defintion)

# /api/App Internals/Bindings/Batman.DOM.AttributeBinding

- `data-bind-#{attribute}="value"`

Extended by:
- `Batman.DOM.AddClassBinding`
- `Batman.DOM.EventBinding`

## ::onlyObserve[="data"]
## ::dataChange(value)
## ::nodeChange(node)

# /api/App Internals/Bindings/Batman.DOM.AbstractCollectionBinding

Extended by:
- `Batman.DOM.ClassBinding`
- `Batman.DOM.IteratorBinding`
- `Batman.DOM.StyleBinding`

## ::dataChange(collection)
## ::bindCollection(newCollection)
## ::unbindCollection()
## ::handleArrayChanged()
## ::die()

# /api/App Internals/Bindings/Batman.DOM.NodeAttributeBinding

Extended by:
- `Batman.DOM.CheckedBinding`
- `Batman.DOM.StyleAttributeBinding`

## ::dataChange(value = "")
## ::nodeChange(node)

# /api/App Internals/Bindings/Batman.DOM.ContextBinding

Extended by:
- `Batman.DOM.FormBinding`

## ::onlyObserve[="data"]
## ::backWithView[=true]
## ::constructor(definition)
## ::dataChange(proxiedObject)
## ::die()

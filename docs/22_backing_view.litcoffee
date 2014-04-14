# /api/App Internals/Views

Under the hood, batman.js uses several specialized views to implement data binding.

# /api/App Internals/Views/Batman.IteratorView

`Batman.IteratorView` extends `Batman.View`. It is instantiated by `data-foreach` bindings.

By default, `Batman.IteratorView` wraps elements in a plain `Batman.View`, but you can provide a custom view for each item by putting a `data-view` binding on the node with the `data-foreach` binding.

For example:

```html
<ul>
  <li data-foreach-item='collection' data-view='ItemListingView'>
    <!-- Will use App.ItemListingView -->
  </li>
</ul>
```

## ::loadView : HTMLElement

Returns a comment element which becomes the `@node` for the view.

## ::addItems(items : Array, indexes : Array)

Adds subviews for `items` by cloning `@prototypeNode`. If `indexes` aren't passed, items are added to the end of the iterator view's subviews.

## ::removeItems(items : Array, indexes : Array)

Removes corresponding subviews for `items`. More performant if `indexes` are passed.

## ::moveItem(oldIndex, newIndex)

Reorders `@subviews` so that the item at `oldIndex` is now at `newIndex`.

## ::.iteratorName : String

The name passed as `data-foreach-#{iteratorName}`.

## ::.iteratorPath : String

The keypath passed to the binding as `data-foreach-#{iteratorName}="#{iteratorPath}"`

## ::.attributeName : String

The `attr` passed to the `data-foreach` binding. Identical to `iteratorName`.

## ::.prototypeNode

The node with the `data-foreach` binding. `@prototypeNode` is copied for each item in the bound collection

## ::.iterationViewClass : View

The `Batman.View` instantiated for each item in the bound collection. You can provide an `@iterationViewClass` by putting a `data-view` binding on the "prototype node."

If no class is provided, `Batman.IterationView` will be used.


# /api/App Internals/Views/Batman.IterationView

`Batman.IterationView` extends `Batman.View`. It has no added functionality. It is used by `Batman.IteratorView` if no other item-level view class is provided to the `prototypeNode` with a `data-view` binding.

# /api/App Internals/Views/Batman.BackingView

`Batman.BackingView` is instantiated by some bindings to keep track of nodes and data.

## ::.isBackingView[=true]
## ::.bindImmediately[=false]

# /api/App Internals/Views/Batman.SelectView

`Batman.SelectView` is the backing view for a `Batman.DOM.SelectBinding`. It fires `childBindingAdded` whenever a new child binding is added. (This event is observed by the select binding.)

# /api/Extras/Batman.Paginator

`Batman.Paginator` is an abstract class which is implemented by `Batman.ModelPaginator`. For information about paginating records, see `Batman.ModelPaginator`.


Internally, `Batman.Paginator` prevents loading the same page twice.

## ::constructor(options={}) : Paginator

Returns a new paginator, mixing in `options`. `options` may include:

- `limit`
- `offset` or `page`
- `totalCount`

## ::loadItemsForOffsetAndLimit(offset, limit)

Implementations of `Batman.Paginator` must implement this function. See `Batman.ModelPaginator` for an example.

This function should load items, then call `@updateCache(offset, limit, items)`.

Internally, `Batman.Paginator`:

- prevents reloading a page when it's still loading
- prevents loading a page twice

## ::%toArray : Array

Returns an array of items in the current `page`. This property depends on `offset` and `limit`, so changing `offset`, `limit` or `page` will automatically update `toArray`.

## ::nextPage()

Increments the current `page`, causing `toArray` to be updated.

## ::previousPage()

Decrements the current `page`, causing `toArray` to be updated.

## ::%page : Number

Current page number, determined by `offset` and `limit`. Setting `page` automatically increases `offset`.

Since `toArray` depends on `offset`, setting `page` will also cause `toArray` to be updated.

## ::%offset : Number

Number of items skipped for the current `page`.

## ::%limit : Number

Items per page.

## ::%totalCount : Number

Total number of records covered by the `Paginator`.

## ::%pageCount : Number

Total number of pages covered by the `Paginator`, calculated from `totalCount` and `limit`.

## ::updateCache(offset, limit, items)

Registers `items` as the items from `offset` for `limit`. This should be called by `loadItemsForOffsetAndLimit` to inform the paginator of loaded records.

# /api/Extras/Batman.Paginator/Batman.ModelPaginator

`Batman.ModelPaginator` is a concrete implementation of `Batman.Paginator`. It may be used for paginating `Batman.Model` instances.

A `Batman.ModelPaginator` provides pagination by:

- Taking `model`, `limit`, `params`, and `page`/`offset` as input
- Exposing records by its `toArray` property (eg, `paginator.get('toArray')`)

## Using Batman.ModelPaginator

Add a paginator to your controller:

```coffee
class App.PostsController extends Batman.Controller
  index: -> # renders posts/index.html
    @set 'paginator, new Batman.ModelPaginator
      model: App.Post
      limit: 10
      page: 1
      params: {order: "created_at"}
```

Then, bind to it in your HTML:

```html
<ul>
  <li data-foreach-post='paginator.toArray'>
    <span data-bind='post.name'></span>
  </li>
</ul>
<button data-event-click='paginator.previousPage'>Prev</button>
<button data-event-click='paginator.nextPage'>    Next</button>
```


## ::constructor(options) : ModelPaginator

Besides the options passed to `Batman.Paginator`, you may also pass:

- `model`: A `Batman.Model` class whose records are paginated
- `params` : A plain JS object which will be used when loading items from the server

## ::loadItemsForOffsetAndLimit(offset, limit)

Loads records by calling `@model.load` with:

- any key/values passed as `@params`
- `offset` and `limit`

## ::.params : Object

A plain JavaScript object whose key-value pairs will be passed to `@model.load` when loading records.

## ::.model : Class

A `Batman.Model` subclass whose records are paginated by the `ModelPaginator`.



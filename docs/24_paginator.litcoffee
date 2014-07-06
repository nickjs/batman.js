# /api/Extras/Batman.Paginator

`Batman.Paginator` is an abstract class which is implemented by `Batman.ModelPaginator`. For information about paginating records, see `Batman.ModelPaginator`.


`Batman.Paginator` provides:

- exposing pages of records (via `toArray`) and changing pages (`nextPage` / `previousPage`)
- item caching and  prevention of reloading/concurrent loading of pages
- calculation calucations for `page`, `offset`, `limit`, etc.

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

```coffeescript
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

If you want your paginator to update from other properties, wrap it in `@accessor`. For example, to make a new paginator when `postsOrder` changes, you could:


```coffeescript
class App.PostsController extends Batman.Controller
  index: ->
    @set('postsOrder', 'created_at')
    # renders posts/index.html

  @accessor 'paginator,
    new Batman.ModelPaginator
      model: App.Post
      limit: 10
      page: 1
      params: {order: @get('postsOrder')}
```

Now, if you set `postsOrder` to `length`, it would cause `paginator` to be reevaluated, and the new paginator would use `order=length` to load records. Also, `paginator.toArray` would be updated with the new records in the new order.

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



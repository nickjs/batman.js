# /api/App Components/Batman.App/Batman.App Routing

The batman.js routing DSL is similar to the [Rails routing DSL](http://guides.rubyonrails.org/routing.html). It is oriented around the notion of a resource.

## Handling unknown routes

When batman.js doesn't have a way to handle a route, it:

- fires `"error"` on the running app, passing an object like:
  ```javascript
  {
    type: "404"
    isPrevented: false
    preventDefault: -> @isPrevented = true
  }
  ```
- if `error.isPrevented` isn't set to `true` by a handler, redirects to `/404`

So, you can handle these in your App routing:

```coffeescript
class MyApp extends Batman.App
  # handle the event:
  @on 'error', ->
    if error.type is "404"
      alert('Not Found!')
      error.preventDefault()
```

__or:__

```coffeescript
class MyApp extends Batman.App
  # handle the redirect:
  @route '/404', (params) -> alert("Not found!")
```

## @route

`@route` defines a custom route and can be pointed to a controller action directly. For example:

```coffeescript
class window.Example extends Batman.App
  @route 'comments', 'pages#comments'

class Example.PagesController extends Batman.Controller
  comments: ->
```

Would result in `/comments` being added to the routing map, pointed to `PagesController#comments`.


## @resources(resourceName : String[, otherResourceNames... : String][, options : Object][, scopedCallback : Function])

`@resources` is modeled after the Rails routing `resources` method. It automatically defines some routes and matches them to controller actions. For example,

```coffeescript
class App extends Batman.App
  @resources 'pages'

class App.PagesController extends Batman.Controller
  index: ->
    # ...
  new: ->
    # ...
  show: (params) ->
    App.Page.find params.id, (err, page) ->
      @set('currentPage', page)
  edit: (params) ->
    App.Page.find params.id, (err, page) ->
      @set('currentPage', page)
```

Will set up these routes:

Path | Controller Action
-- | -- |
/pages | App.PagesController#index
/pages/new | App.PagesController#new
/pages/:id | App.PagesController#show
/pages/:id/edit | App.PagesController#edit

Note that unlike Rails, `destroy`, `update`, and `create` are not performed by controller actions in batman.js. Instead, call `save` or `destroy` on your records directly.
To access a generated route from within a view, use the [`data-route` binding](batman.view_bindings.html#data-route).

### Nested Resources

You may also nest resources, as in Rails:

```coffeescript
class App extends Batman.App
  @resources 'pages', ->
    @resources 'comments'
```

Will set up these routes for `App.Comment`:

Path | Controller Action
-- | -- |
/pages/:page_id/comments | App.CommentsController#index
/pages/:page_id/comments/new | App.CommentsController#new
/pages/:page_id/comments/:id | App.CommentsController#show
/pages/:page_id/comments/:id/edit | App.CommentsController#edit


## @member

`@member` defines a routable action you can call on a specific instance of a member of a collection resource. For example, if you have a collection of `Page` resources, and a user can post a comment on a specific page:

```coffeescript
class window.Example extends Batman.App
  @resources 'pages', ->
    @member 'comment'

class Example.PagesController extends Batman.Controller
  comment: (params) ->
```

Would result in `/pages/:id/comment` being added to the routing map, pointed to `PagesController#comment`.

## @collection

`@collection` is similar to `@member` in that it adds routable actions to a `@resources` set of routes. In this case the action would apply to the entire collection. For example, if you have a list of spam comments made across _all_ your `Page` resources:

```coffeescript
class window.Example extends Batman.App
  @resources 'pages', ->
    @collection 'spam_comments'

class Example.PagesController extends Batman.Controller
  comments: ->
```

Would result in `/pages/spam_comments` being added to the routing map, pointed to `PagesController#spam_comments`.

## @root

`@root` defines the root controller and action to be used when visiting the base application URL. For example:

```coffeescript
class window.Example extends Batman.App
  @root 'pages#index'

class Example.PagesController extends Batman.Controller
  index: ->
```

Would result in `/` being pointed to `PagesController#index`.

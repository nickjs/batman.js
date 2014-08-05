# /api/App Components/Batman.View/Batman.View Lifecycle

When [`Batman.View`](/docs/api/batman.view.html) is rendered, it goes through many steps. Lifecycle callbacks allow you to hook into those steps and control or respond to the rendering process.

### Listening for Lifecycle Events

To set up handlers for a `View`'s lifecycle, You can either call [`on`](/docs/api/batman.eventemitter.html#prototype_function_on) on the `View`'s  prototype:

```coffeescript
class MyApp.FadingView extends Batman.View
  @::on 'viewWillAppear', -> $(@get('node')).hide()

  @::on 'viewDidAppear', -> $(@get('node')).fadeIn('fast')

  @::on 'viewWillDisappear', -> $(@get('node')).fadeOut('fast')
```

or define functions with the same name as the events:

```coffeescript
class MyApp.FadingView extends Batman.View
  viewWillAppear: -> $(@get('node')).hide()

  viewDidAppear: -> $(@get('node')).fadeIn('fast')

  viewWillDisappear: -> $(@get('node')).fadeOut('fast')
```

### Lifecycle Events and Subviews

A `View` propagates its lifecycle events to its [`subviews`](/docs/api/batman.view.html#prototype_property_subviews), so it's likely that a lifecycle event will be called more than once. `ready` is an exception -- it's a one-shot event.

## viewWillAppear

The view is about to be attached to the DOM. It has a [`superview`](/docs/api/batman.view.html#prototype_property_superview).

## viewDidAppear

The view has just been attached to the DOM. Its [`node`](/docs/api/batman.view.html#prototype_accessor_node) is on the page and can be selected with `document.querySelector`.

## viewDidLoad

The view's [`node`](/docs/api/batman.view.html#prototype_accessor_node) has been loaded from its [`html`](/docs/api/batman.view.html#prototype_accessor_html)). It may not be in the DOM yet.

## ready

The view's bindings have been initialized. The view may or may not be in the DOM. `ready` is a one-shot event.

## viewWillDisappear

The view is about to be detached from the DOM. It still has a [`superview`](/docs/api/batman.view.html#prototype_property_superview) and its [`node`](/docs/api/batman.view.html#prototype_accessor_node) is still selectable.

## viewDidDisappear

The view has been detached from the DOM. It still has a [`superview`](/docs/api/batman.view.html#prototype_property_superview) but its [`node`](/docs/api/batman.view.html#prototype_accessor_node) is not selectable.

## destroy

[`die`](/docs/api/batman.view.html#prototype_function_die) was called on this view. It will be removed from its superview, removed from the DOM, and have all of its properties set to `null`.

## viewDidMoveToSuperview

The view has been attached to its [`superview`](/docs/api/batman.view.html#prototype_property_superview), but it is not yet in the DOM.

## viewWillRemoveFromSuperview

The view is about removed from its [`superview`](/docs/api/batman.view.html#prototype_property_superview), then it will be detached from the DOM.

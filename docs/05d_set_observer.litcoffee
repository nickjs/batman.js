# /api/Data Structures/Batman.Set/Batman.SetObserver

`Batman.SetObserver` is a utility for observing `Batman.Set`s and their contents (especially if their contents are `Batman.Object`s). It extends `Batman.Object`. In the wild, `Batman.SetProxy` uses a `Batman.SetObserver` to track its base set and `Batman.SetSort` uses item tracking to maintain its order.

A few other points about `Batman.SetObserver`:

- It fires `itemsWereAdded` and `itemsWereRemoved` when its base `Batman.Set` fires those events.
- When items are added and removed to the base Set, they're automatically observed with `startObservingItems`/`stopObservingItems` -- you don't have to set that up yourself.
- Override `observedItemKeys` and `observerForItemAndKey` to track properties of `Batman.Object` members of the set.

## ::constructor(base : Set) : SetObserver

Returns a new `Batman.SetObserver` tracking `base`.

## ::.base : Set

The set being tracked by the observer.

## ::.observedItemKeys[=[]]: Array

If you set `observedItemKeys` to an array of strings, those keys will be observed on the members of `base`. When those keys change, the provided observer (see `observerForItemAndKey`) will be called.

## ::.observerForItemAndKey(item : Batman.Object, key : String) : Function

When you instantiate a `SetObserver`, you should override this function. When the observer starts observing an item, this function will be called for each `key` in `observedItemKeys`. It should return an observer function for `key`. The observer function will be passed `newValue, oldValue`.

## ::startObserving()

Starts observing the `base` and all its members.

## ::stopObserving()

Stops observing the `base` and all its members.

## ::startObservingItems(items : Array)

Adds observers for `observedItemKeys` on each item in `items`, calling `observerForItemAndKey` for each key in `observedItemKeys`

## ::stopObservingItems(items : Array)

Forgets observers on `items`.


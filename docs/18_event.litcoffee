# /api/Data Structures/Batman.Event

`Batman.Event`s are the events which are managed by `Batman.EventEmitter`s.

## ::constructor(base, key: String) : Event

Returns a new `Event` with `base` and `key`.

## ::.base

Returns `base` specified in the constructor. `base` represents the object the `Event` happens _on_.

## ::.key

Returns `key` specified in the constructor. `key` is like the _name_ of the `Event`.

## ::.handlers : Array

Returns all `handlers` on the `Event`. May return `undefined` if no handlers have been added.

## ::.oneShot : Boolean

## @forBaseAndKey(base, key: String) : Event

If `base.isEventEmitter`, gets an `Event` from `base.event(key)`, otherwise constructs a new `Event` with `base` and key`.

## ::isEvent[=true ] : Boolean

Returns `true`.

## ::isEqual(other: Event) : Boolean

Returns `true` if `other`'s `constructor`, `base`, and `key` match the `Event`'s `constructor`, `base`, and `key`.

## ::hashKey() : String

Returns a string representation of the `Event`.

## ::addHandler(handler: Function) : Event

Adds `handler` to the `Event`'s `handlers` if it isn't already present. If `oneShot` is `true` the `Event` will pass the handler to `autofireHandler`.

## ::removeHandler(handler: Function) : Event

Removes `handler` from the `Event`'s `handlers` if it present.

## ::eachHandler(iterator: Function)

Calls `iterator(handler)` for each item in `handlers`. If `base.isEventEmitter`, also checks for `_batman.ancestors()` and calls `iterator(handler)` for handlers on ancestors.

## ::clearHandlers()

Sets `handlers` to `undefined`.

## ::handlerContext()

Returns `base`.

## ::prevent()

Prevents `Event` from being fired. `Event` must be `allow`ed once for each time it was `prevent`ed, so if `prevent` was called twice, `allow` must be called twice.

## ::allow()

Allows `Event` to be fired if it was prevented.

## ::isPrevented() : Boolean

Returns `true` if `Event` had been `prevent`ed more than it has been `allow`ed.

## ::autofireHandler(handler: Function)

If `Event.oneShot` was `true` when it was fired, calls `handler` with context and arguments from when it was fired.

## ::resetOneShot()

Resets a `oneShot` `Event` so that it may be fired again.

## ::fire(args)

Fires the event on `base`, passing `args` to all handlers.

## ::fireWithContext(context, args)

Fires the event on `context`, passing `args` to all handlers.

## ::allowAndFire(args)

Allows and fires the event on `base`, passing `args` to all handlers. If `prevent` was called more than once, the `Event` may still be prevented.

## ::allowAndFireWithContext(context, args)

Allows and fires the event on `context`, passing `args` to all handlers. If `prevent` was called more than once, the `Event` may still be prevented.


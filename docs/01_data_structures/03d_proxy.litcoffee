# /api/Data Structures/Batman.Object/Batman.Proxy

`Batman.Proxy` extends `Batman.Object` but implements the default accessor to `get`, `set`, and `unset` on its `target`.

Any accessors without explicit definitions will be delegated to `target`:

    test "a Batman.Proxy delegates to its target", ->
      class CustomProxy extends Batman.Proxy
        @accessor 'customValue', -> "Custom Value!"

      targetObject = new Batman.Object({name: "Batman", favoriteColor: "#000"})
      proxy = new CustomProxy(targetObject)

      equal proxy.get('favoriteColor'), '#000', "Default accessor delegates to target"
      equal proxy.get('customValue'), "Custom Value!", "Custom accessors override delegated ones"

## ::constructor(target : Batman.Object) : Proxy

Returns a new `Batman.Proxy` delegating to `target`.

## ::.isProxy[=true] : Boolean

Returns `true`. Shows that the object is a proxy.

## ::%target : Object

Returns the object which the `Proxy` is delegating to.

## @delegatesToTarget(functionNames...)

Defines a whitelist of functions which the `Proxy` will delegate to its target object. Unlike accessors, functions are not automatically passed to the target. For example:

    class Batman.AssociationProxy
      ...
      @delegatesToTarget('save', 'validate', 'destroy')
      ...

passes calls to `save`, `validate`, and `destroy` made on an `AssociationProxy` to the target `Batman.Model` where those functions are defined.

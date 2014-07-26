# /api/App Internals/Batman.Transaction

`Batman.Transaction` is mixed into the new record created by `Batman.Model::transaction`. It redefines and adds a few functions so that the resulting "transaction" will behave like a model. For example:

```coffeescript
product = new App.Product(name: "Orange Glo")
productTransaction = product.transaction()
productTransaction.set("name", "Sham-Wow")
# Changing the transaction doesn't affect the base record:
product.get('name') # "Orange Glo"
# Until changes are applied:
productTransaction.save()
product.get('name') # "Sham-Wow"
```

## ::isTransaction[=true] : Boolean

Shows that this `Batman.Model` is actually a transaction.

## ::base() : Model

Returns the `Batman.Model` that this transaction came from.

## ::applyChanges(visited[=[]] : Array) : Model

Applies changes from the transaction to the base `Batman.Model`. `visited` is an array of models which have already had their changes applied (so that those models don't have their changes applied repeatedly).

Calling `applyChanges` also applies changes on associated records.

Returns the base `Batman.Model`.

## ::save(callback)

Meant to behave just like `Batman.Model::save`. The callback will be called with `(error, record, env)`. Calling `save` on a transaction:
- Validates the transaction
- If validation was successful, applies changes
- If validation was successful, saves the record

# /api/App Internals/Batman.Transaction/Batman.TransactionAssociationSet

`Batman.TransactionAssociationSet` is a `Batman.Set` used for transactions of has-many associations. It isolates the original `Batman.AssociationSet` from any changes to the items _or_ any added or removed items until `applyChanges` is called.

A `Batman.TransactionAssociationSet` adds any items that are added to its base set during the transaction. This is so that, if the association is being loaded, the newly-loaded items will appear in the transaction.

Calling `save` on a `Batman.Transaction` model applies changes to its associations as well, so it's rare to interact with a `Batman.TransactionAssociationSet` directly.

After calling `save`, you can access items that were _removed_ from the association set during the transaction at `removedItems`, for example:

```coffeescript
parent = parentTransaction.save() # applies changes
removedChildren = parent.get('children.removedItems')
# Returns `children` that were removed during the transaction
```

## ::constructor(associationSet, visited : Array, stack : Array) : TransactionAssociationSet

Creates a new `Batman.TransactionAssociationSet` based on `associationSet`. It loads the members of `associationSet` and observes it for `"itemsWereAdded"`, adding any items to itself that are added to the base set.

## ::build(attributes : Object) : Model

Builds a new instance of the associated model, with `attributes` mixed in, then adds it to the `TransactionAssociationSet`.

## ::add(items...) : Array

Adds `items` to the `TransactionAssociationSet`. Items are expected to _not_ be transactions: they will be made into transactions by `add`.

The transaction is added to the set and the original item is also tracked by the set (for the purpose of applying changes). If an item was previously removed, it is no longer considered to be removed.

Fires `itemsWereAdded` with the added transactions and returns an array of added transactions.

## ::remove(transactions...) : Array

Removes `transactions` from the set. These items are still tracked by the set: after `applyChanges`, they'll be available as `removedItems` on the base association set.

If an item is removed, then added back, it is not put in the `removedItems` set during `applyChanges`.

## ::applyChanges

Applies changes to the base `AssociationSet` by:

- calling `applyChanges` on each item in the set
- replacing the `AssociationSet`'s contents with the updated contents
- putting any removed items in the `AssociationSet`'s  `"removedItems"`.

## ::%associationSet

The base `Batman.AssociationSet` for this transaction.

## ::%association : Association

The `Batman.Association` object from the base `Batman.Association`.

## ::%foreignKeyValue

The `foreignKeyValue` from the base `Batman.Association`.

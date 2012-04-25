{createStorageAdapter, TestStorageAdapter, AsyncTestStorageAdapter, generateSorterOnProperty} = if typeof require isnt 'undefined' then require '../model_helper' else window
helpers = if typeof require is 'undefined' then window.viewHelpers else require '../../view/view_helper'
{baseSetup} = if typeof require is 'undefined' then window.PolymorphicAssociationHelpers else require './polymorphic_association_helper'

{createStorageAdapter, TestStorageAdapter, AsyncTestStorageAdapter, generateSorterOnProperty} = window
helpers = window.viewHelpers
{baseSetup} = if typeof require is 'undefined' then window.PolymorphicAssociationHelpers else require './polymorphic_association_helper'

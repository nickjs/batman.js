#= require ../model
#= require association_curator

for k in Batman.AssociationCurator.availableAssociations
  do (k) =>
    Batman.Model[k] = (label, scope) ->
      Batman.initializeObject(@)
      collection = @_batman.associations ||= new Batman.AssociationCurator(@)
      collection.add new Batman["#{helpers.capitalize(k)}Association"](@, label, scope)


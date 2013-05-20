helpers = require 'sha_summarizer'

keys = ['IteratorBinding performance: loop over an array of 200 items with 3 bindings',
        'IteratorBinding performance: loop over an array of 400 items with 3 bindings',
        'IteratorBinding performance: loop over an array of 200 items with repaint-y bindings']
shas = helpers.getAvailableShas(keys)

keys.forEach (key) ->
  header "#{key} Render Speed (milliseconds)"
  barchart helpers.reportKeyAcrossShasAndAgents(key, shas)

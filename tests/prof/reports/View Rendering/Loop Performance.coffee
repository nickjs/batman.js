helpers = require 'sha_summarizer'
qs = (length) -> ('?' for i in [0...length]).join(', ')

keys = ['IteratorBinding performance: loop over an array of 50 items',
        'IteratorBinding performance: loop over an array of 100 items',
        'IteratorBinding performance: loop over an array of 150 items',
        'IteratorBinding performance: move one item from the top to the bottom of the set',
        'IteratorBinding performance: reverse the set']
shas = helpers.getAvailableShas(keys)

keys[0..2].forEach (key) ->
  header "#{key} Render Speed (milliseconds)"
  barchart helpers.reportKeyAcrossShasAndAgents(key, shas)

key = keys[3]
header "#{key} Render Speed (milliseconds)"
barchart helpers.reportKeyAcrossShasAndAgents(key, shas)

key = keys[4]
header "#{key} Render Speed (milliseconds)"
barchart helpers.reportKeyAcrossShasAndAgents(key, shas)

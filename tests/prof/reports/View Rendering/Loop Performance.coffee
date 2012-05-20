helpers = require 'sha_summarizer'
qs = (length) -> ('?' for i in [0...length]).join(', ')

keys = ['IteratorBinding performance: loop over an array of 50 items', 'IteratorBinding performance: loop over an array of 100 items', 'IteratorBinding performance: loop over an array of 150 items']
shas = helpers.getAvailableShas(keys)

header "Render Speed"
barchart helpers.reportKeysAcrossShas(keys, shas)


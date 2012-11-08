helpers = require 'sha_summarizer'

header "Simple Rendering Benchmarks (milliseconds)"

keys = ['simple view rendering: nested loop rendering', 'simple view rendering: simple bindings rendering', 'simple view rendering: simple loop rendering']
shas = helpers.getAvailableShas(keys)

barchart helpers.reportKeysAcrossShas(keys, shas)

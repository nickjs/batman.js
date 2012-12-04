helpers = require 'sha_summarizer'

header "Raw Node Parsing"

keys = ['parseNode function: 1000 divs without bindings', 'parseNode function: 1000 divs with one binding', 'parseNode function: 1000 divs with 10 bindings', 'parseNode function: 1000 deeply nested divs', 'parseNode function: 1000 deeply nested divs with one binding', 'parseNode function: 1000 deeply nested divs with 10 bindings']
shas = helpers.getAvailableShas(keys)

header "No Bindings (milliseconds)"
barchart helpers.reportKeysAcrossShas([keys[0], keys[3]], shas)

header "One Binding (milliseconds)"
barchart helpers.reportKeysAcrossShas([keys[1], keys[4]], shas)

header "10 Bindings (milliseconds)"
barchart helpers.reportKeysAcrossShas([keys[2], keys[5]], shas)

header "10 Attribute Bindings (milliseconds)"
barchart helpers.reportKeysAcrossShas([keys[2], keys[5]], shas)


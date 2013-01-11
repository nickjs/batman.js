helpers = require 'sha_summarizer'

keys = ['property getting: getting with no sources', 'property getting: getting with 1 source', 'property getting: getting with 3 sources']
shas = helpers.getAvailableShas(keys)

header "Getting w/0 (milliseconds)"
barchart helpers.reportKeysAcrossShas([keys[0]], shas)

header "Getting w/1 (milliseconds)"
barchart helpers.reportKeysAcrossShas([keys[1]], shas)

header "Getting w/3 (milliseconds)"
barchart helpers.reportKeysAcrossShas([keys[2]], shas)

helpers = require 'sha_summarizer'
keys = ["object instantiation: vanilla object creation", "object instantiation: clunk creation"]
shas = helpers.getAvailableShas(keys)

header "Instantiation Speed (milliseconds)"
barchart helpers.reportKeysAcrossShas([keys[0]], shas)

header "Instantiation Speed with many keys (milliseconds)"
barchart helpers.reportKeysAcrossShas([keys[1]], shas)


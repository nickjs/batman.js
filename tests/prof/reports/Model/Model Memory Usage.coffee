helpers = require 'sha_summarizer'

keys = ["models with 0 attributes","models with 5 attributes","models with 50 attributes"]
shas = helpers.getAvailableShas(keys)

header "Batman.Models with 0 Attributes"
linechart helpers.summarizeShasForKey(shas, keys[0])

header "Batman.Models with 5 Attributes"
linechart helpers.summarizeShasForKey(shas, keys[1])

header "Batman.Models with 50 Attributes"
linechart helpers.summarizeShasForKey(shas, keys[2])

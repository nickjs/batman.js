helpers = require 'sha_summarizer'

header "Object Overhead"

keys = ["object instantiation memory usage", "object instantiation with observers memory usage", "observer attachement memory usage"]
shas = helpers.getAvailableShas(keys)

header "Objects (megabytes)"
linechart helpers.summarizeShasForKey(shas, keys[0])

header "Objects with Observers and Events (megabytes)"
linechart helpers.summarizeShasForKey(shas, keys[1])

header "Observer and Events Only (megabytes)"
linechart helpers.summarizeShasForKey(shas, keys[2])


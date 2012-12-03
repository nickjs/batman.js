helpers = require 'sha_summarizer'

header "View Memory Usage"

keys = ["view memory usage: simple", "view memory usage: loop rendering", "view memory usage: loop rendering with clear"]
shas = helpers.getAvailableShas(keys)

header "Simple (megabytes)"
linechart helpers.summarizeShasForKey(shas, keys[0])

header "Loop rendering (megabytes)"
linechart helpers.summarizeShasForKey(shas, keys[1])

header "Loop rendering with clear (megabytes)"
linechart helpers.summarizeShasForKey(shas, keys[2])

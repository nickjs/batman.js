glob = require 'glob'
Snockets = require 'snockets'

snockets = new Snockets()
snockets.scan 'src/manifest.coffee', {async: false}

all = glob.sync('src/**/*.coffee')
chain = snockets.depGraph.getChain 'src/manifest.coffee'

console.dir all.filter((x) -> chain.indexOf(x) == -1)

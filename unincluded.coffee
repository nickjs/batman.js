glob = require 'glob'
Snockets = require 'snockets'

snockets = new Snockets()
snockets.scan 'src/batman.coffee', {async: false}

all = glob.sync('src/**/*.coffee')
console.log chain = snockets.depGraph.getChain 'src/batman.coffee'

#console.dir all.filter((x) -> chain.indexOf(x) == -1)

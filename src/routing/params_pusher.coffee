#= require params_replacer

class Batman.ParamsPusher extends Batman.ParamsReplacer
  redirect: -> @navigator.push(@toObject())

Paginator = require './paginator'

module.exports = class ModelPaginator extends Paginator
  cachePadding: 0
  paddedOffset: (offset) ->
    offset -= @cachePadding
    if offset < 0 then 0 else offset
  paddedLimit: (limit) ->
    limit + @cachePadding * 2

  loadItemsForOffsetAndLimit: (offset, limit) ->
    params = @paramsForOffsetAndLimit(offset, limit)
    params[k] = v for k,v of @params
    @model.load params, (err, records, env) =>
      if err?
        @markAsFinishedLoading()
        @fire('error', err)
      else
        @set('totalCount', env.response[@totalCountKey]);
        @updateCache(@offsetFromParams(params), @limitFromParams(params), records)

  # override these to fetch records however you like:
  paramsForOffsetAndLimit: (offset, limit) ->
    offset: @paddedOffset(offset), limit: @paddedLimit(limit)
  offsetFromParams: (params) -> params.offset
  limitFromParams: (params) -> params.limit

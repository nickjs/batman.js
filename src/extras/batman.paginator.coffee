class Batman.Paginator extends Batman.Object
  class @Range
    constructor: (@offset, @limit) ->
      @reach = offset + limit
    coversOffsetAndLimit: (offset, limit) ->
      offset >= @offset and (offset + limit) <= @reach

  class @Cache extends @Range
    constructor: (@offset, @limit, @items) ->
      super
      @length = items.length
    itemsForOffsetAndLimit: (offset, limit) ->
      begin = offset-@offset
      end = begin + limit
      if begin < 0
        padding = new Array(-begin)
        begin = 0
      slice = @items.slice(begin, end)
      if padding
        padding.concat(slice)
      else
        slice

  offset: 0
  limit: 10
  totalCount: 0

  markAsLoadingOffsetAndLimit: (offset, limit) -> @loadingRange = new Batman.Paginator.Range(offset, limit)
  markAsFinishedLoading: -> delete @loadingRange

  offsetFromPageAndLimit: (page, limit) -> Math.round((+page - 1) * limit)
  pageFromOffsetAndLimit: (offset, limit) -> offset / limit + 1

  _load: (offset, limit) ->
    return if @loadingRange?.coversOffsetAndLimit(offset, limit)
    @markAsLoadingOffsetAndLimit(offset, limit)
    @loadItemsForOffsetAndLimit(offset, limit)

  toArray: ->
    cache = @get('cache')
    offset = @get('offset')
    limit = @get('limit')
    @_load(offset, limit) unless cache?.coversOffsetAndLimit(offset, limit)
    cache?.itemsForOffsetAndLimit(offset, limit) or []
  page: ->
    @pageFromOffsetAndLimit(@get('offset'), @get('limit'))
  pageCount: ->
    Math.ceil(@get('totalCount') / @get('limit'))

  previousPage: -> @set('page', @get('page')-1)
  nextPage: -> @set('page', @get('page')+1)

  loadItemsForOffsetAndLimit: (offset, limit) -> # override on subclasses or instances
  updateCache: (offset, limit, items) ->
    cache = new Batman.Paginator.Cache(offset, limit, items)
    return if @loadingRange? and not cache.coversOffsetAndLimit(@loadingRange.offset, @loadingRange.limit)
    @markAsFinishedLoading()
    @set('cache', cache)
  @accessor 'toArray', @::toArray
  @accessor 'offset', 'limit', 'totalCount',
    get: Batman.Property.defaultAccessor.get
    set: (key, value) -> Batman.Property.defaultAccessor.set.call(this, key, +value)
  @accessor 'page',
    get: @::page
    set: (_,value) ->
      value = +value
      @set('offset', @offsetFromPageAndLimit(value, @get('limit')))
      value
  @accessor 'pageCount', @::pageCount

class Batman.ModelPaginator extends Batman.Paginator
  cachePadding: 0
  paddedOffset: (offset) ->
    offset -= @cachePadding
    if offset < 0 then 0 else offset
  paddedLimit: (limit) ->
    limit + @cachePadding * 2

  loadItemsForOffsetAndLimit: (offset, limit) ->
    params = @paramsForOffsetAndLimit(offset, limit)
    params[k] = v for k,v of @params
    @model.load params, (err, records) =>
      if err?
        @markAsFinishedLoading()
        @fire('error', err)
      else
        @updateCache(@offsetFromParams(params), @limitFromParams(params), records)

  # override these to fetch records however you like:
  paramsForOffsetAndLimit: (offset, limit) ->
    offset: @paddedOffset(offset), limit: @paddedLimit(limit)
  offsetFromParams: (params) -> params.offset
  limitFromParams: (params) -> params.limit

class DressMonad

  constructor: (@world, @result, @error)->

  success: (result)->
    new DressMonad @world, result, undefined

  failure: (context, error, causes)->
    error = { error: error }
    error.children = causes if causes?
    new DressMonad @world, undefined, error

  find: (collection, callback, onFailure)->
    causes = []
    for i in [0...collection.length]
      element = collection[i]
      m = callback(element, i)
      if m.isSuccess()
        return m
      else
        setErrorLocation(m.error, element, i) unless m.error.location?
        causes.push(m.error)
    onFailure(causes)

  refine: (base, collection, callback, onFailure)->
    if base.isSuccess()
      causes = []
      for i in [0...collection.length]
        element = collection[i]
        m = callback(base, element, i)
        if m.isFailure()
          setErrorLocation(m.error, element, i) unless m.error.location?
          causes.push(m.error)
          break if @isFailfast()
      return base if causes.length == 0
      onFailure(causes)
    else
      onFailure([base.error])

  map: (collection, mapper, onFailure)->
    result  = []
    success = @success result
    callback = (_, elm, index)->
      m = mapper(elm, index)
      m.onSuccess (elmResult)->
        result.push(elmResult)
        m
    @refine success, collection, callback, onFailure

  isFailfast: ()->
    @world && @world.failfast

  isSuccess: ()->
    @error is undefined

  isFailure: ()->
    not @isSuccess()

  onSuccess: (callback)->
    return this unless @isSuccess()
    callback(@result)

  onFailure: (callback)->
    return this if @isSuccess()
    callback(@error)

setErrorLocation = (error, element, index)->
  loc  = element.name
  loc ?= index
  error.location = loc

module.exports = DressMonad

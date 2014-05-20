Type = require '../type'

#
class AnyType extends Type
  generator: 'any'

  constructor: (@name) ->
    super(@name)

  dress: (value, helper) ->
    value

  defaultName: ->
    "Any"

  include: (value) ->
    true

  isSuperTypeOf: (other)->
    true

  equals: (other) ->
    (other instanceof AnyType) or super

module.exports = AnyType
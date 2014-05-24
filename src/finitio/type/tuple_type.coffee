{TypeType}      = require '../support/ic'
$u              = require '../support/utils'
Type            = require '../type'
Heading         = require '../support/heading'
CollectionType  = require '../support/collection_type'

class TupleType extends Type
  TypeType this, 'tuple', ['heading', 'name', 'metadata']

  constructor: (@heading, @name, @metadata) ->
    unless @heading instanceof Heading
      $u.argumentError("Heading expected, got:", @heading)

    super(@name, @metadata)

  defaultName: ->
    "{#{@heading.toName()}}"

  fetch: ()->
    @heading.fetch.apply(@heading, arguments)

  _include: (value) ->
    return false unless typeof(value) == "object"
    return false unless @areAttributesValid(value)
    $u.every @heading.attributes, (attribute) ->
      if value[attribute.name]?
        attr_val = value[attribute.name]
        attribute.type.include(attr_val)
      else
        true

  _mDress: (value, Monad)->
    unless value instanceof Object
      return Monad.failure this, ["Invalid Tuple `$1`", [value]]

    result  = {}
    success = Monad.success result

    callback = (_, attrName)=>
      attr      = @heading.getAttr(attrName) || null
      attrValue = value[attrName] || null

      if !attrValue? and attr.required
        Monad.failure attrName, ["Missing attribute `$1`", [attrName]]
      else if !attr? and !@heading.allowExtra()
        Monad.failure attrName, ["Unrecognized attribute `$1`", [attrName]]
      else if attr? and attrValue?
        subm = attr.type.mDress(attrValue, Monad)
        subm.onSuccess (val)->
          result[attrName] = val
          success
      else if attrValue?
        result[attrName] = attrValue
        success
      else
        success

    onFailure = (causes)->
      Monad.failure this, ["Invalid Tuple `$1`", [value]], causes

    # build all attributes
    attributes = _attributesHash(@heading)
    $u.extend(attributes, value)
    attributes = Object.keys(attributes)

    Monad.refine success, attributes, callback, onFailure

  _undress: (value, as) ->
    unless as instanceof TupleType
      $u.undressError("Tuple cannot undress to `#{as}` (#{as.constructor}).")

    # Check heading compatibility
    [s, l, r] = $u.triSplit(_attributesHash(@heading), _attributesHash(as.heading))

    # left non empty? do we allow projection undressings?
    unless $u.isEmpty(l)
      $u.undressError("Tuple undress does not allow projecting #{l}")

    # right non empty? do we allow missing attributes?
    unless $u.isEmpty(r)
      $u.undressError("Tuple undress does not support missing #{r}")

    # Do we allow disagreements on required?
    unless $u.every(s, (pair)-> pair[0].required == pair[1].required)
      $u.undressError("Tuple undress requires optional attributes to agree")

    # let undress each attribute in turn
    undressed = {}
    @heading.each (attribute) ->
      attrName  = attribute.name
      attrType  = attribute.type
      attrValue = value[attrName]
      unless attrValue is undefined
        targType  = as.heading.getAttr(attrName).type
        undressed[attribute.name] = attrType.undress(attrValue, targType)

    undressed

  _isSuperTypeOf: (other)->
    (this is other) or
    (other instanceof TupleType and @heading.isSuperHeadingOf(other.heading))

  _equals: (other) ->
    (this is other) or
    (other instanceof TupleType and @heading.equals(other.heading)) or
    super

  ## 'Private' methods

  _attributesHash = (heading)->
    h = {}
    heading.each (a)-> h[a.name] = a
    h

  attributeNames: ->
    $u.map(@heading.attributes, (a) -> a.name)

  requiredAttributeNames: ->
    $u.map(
      $u.values(
        $u.filter(
          @heading.attributes, (a) -> a.required
        )
      ), (a) -> a.name)

  extraAttributes: (value) ->
    $u.difference($u.keys(value), @attributeNames())

  missingAttributes: (value) ->
    $u.difference(@requiredAttributeNames(), $u.keys(value))

  areAttributesValid: (value) ->
    (@heading.allowExtra() || $u.isEmpty(@extraAttributes(value))) &&
      $u.isEmpty(@missingAttributes(value))
#
module.exports = TupleType
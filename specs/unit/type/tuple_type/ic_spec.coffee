Attribute = require '../../../../src/finitio/support/attribute'
Heading   = require '../../../../src/finitio/support/heading'
TupleType = require '../../../../src/finitio/type/tuple_type'
should    = require 'should'
{intType} = require '../../../spec_helpers'

describe "TupleType's information contract", ->

  info = {
    heading: Heading.info({
      attributes: [
        Attribute.info({
          name: 'r',
          type: intType,
          required: false
        })
      ],
      options: { allowExtra: false }
    }),
    metadata: {foo: 'bar'}
  }
  t = TupleType.info(info)

  it 'dresses as expected', ->
    should(t).be.an.instanceof(TupleType)
    should(t.heading).be.an.instanceof(Heading)
    should(t.metadata).eql({ foo: "bar" })

  it 'undresses as expected', ->
    should(t.toInfo()).eql(info)

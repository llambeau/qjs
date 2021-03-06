StructType = require '../../../../src/finitio/type/struct_type'
_          = require 'underscore'
should     = require 'should'
{intType,
floatType} = require '../../../spec_helpers'

describe "StructType#include", ->

  type = new StructType([intType, floatType])

  subject = (arg) ->
    type.include(arg)

  describe 'when a valid array', ->
    arg = [12, 14.1]

    it 'should be true', ->
      subject(arg).should.equal(true)

  describe 'when not an array', ->
    arg = "bar"

    it 'should be false', ->
      subject(arg).should.equal(false)

  describe 'when an invalid array (too few attributes)', ->
    arg = [ 12 ]

    it 'should be false', ->
      subject(arg).should.equal(false)

  context 'when an invalid array (too many attributes)', ->
    arg = [ 12, 14.1, "foo" ]

    it 'should be false', ->
      subject(arg).should.equal(false)

  describe 'when an invalid array (wrong type)', ->
    arg = [ 12, 'bar' ]

    it 'should be false', ->
      subject(arg).should.equal(false)


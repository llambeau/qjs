Attribute     = require '../../../../src/support/attribute'
Heading       = require '../../../../src/support/heading'
RelationType  = require '../../../../src/type/relation_type'
{TypeError}   = require '../../../../src/errors'
_             = require 'underscore'
should        = require 'should'
{byteType}    = require '../../../spec_helpers'

describe "MultiRelationType#dress", ->

  heading = new Heading([
    new Attribute('r', byteType),
    new Attribute('g', byteType),
    new Attribute('b', byteType, false)
  ])

  type = new MultiRelationType(heading, "colors")

  subject = (arg) -> type.dress(arg)

  context 'with a valid array of Hashes', ->
    arg = [
      { "r": 12, "g": 13, "b": 255 },
      { "r": 12, "g": 15, "b": 198 }
    ]

    expected = [
      { r: 12, g: 13, b: 255 },
      { r: 12, g: 15, b: 198 }
    ]

    it 'should coerce to an Array of tuples', ->
      subject.should.be.an.instanceof(Array)
      subject.to_a.should.equal(expected)

  context 'with a valid array of Hashes with some optional missing', ->
    arg = [
      { "r": 12, "g": 13, "b": 255 },
      { "r": 12, "g": 15 }
    ]
    expected = [
      { r: 12, g: 13, b: 255 },
      { r: 12, g: 15 }
    ]

    it 'should coerce to an Array of tuples', ->
      subject.should.be.an.instanceof(Array)
      subject.to_a.should.equal(expected)

  context 'with an empty array', ->
    arg = []
    expected = []

    it 'should coerce to an Array of tuples', ->
      subject.should.be.an.instanceof(Array)
      subject.to_a.should.equal(expected)

  context 'when raising an error', ->

    lambda = (arg) ->
      try
        type.dress(arg)
      catch e
        e

    context 'with something else than an Array', ->
      subject = lambda("foo")

      it 'should raise a TypeError', ->
        subject.should.be.an.instanceof(TypeError)
        subject.message.should.equal("Invalid value `foo` for colors")

      it 'should have no cause', ->
        should(subject.cause).be.null

      it 'should have an empty location', ->
        subject.location.should.equal('')

    context 'with Array of non-tuples', ->
      subject = lambda(["foo"])

      it 'should raise a TypeError', ->
        subject.should.be.an.instanceof(TypeError)
        subject.message.should.equal("Invalid value `foo` for {r: Byte, g: Byte, b :? Byte}")

      it 'should have no cause', ->
        should(subject.cause).be.null

      it 'should have the correct location', ->
        subject.location.should.equal('0')

    context 'with a wrong tuple', ->
      arg = [
        { "r": 12, "g": 13, "b": 255 },
        { "r": 12, "b": 13 }
      ]
      subject = lambda(arg)

      it 'should raise a TypeError', ->
        subject.should.be.an.instanceof(TypeError)
        subject.message.should.equal("Missing attribute `g`")

      it 'should have no cause', ->
        should(subject.cause).be.null

      it 'should have the correct location', ->
        subject.location.should.equal('1')

    context 'with a tuple with extra attribute', ->
      arg = [
        { "r": 12, "g": 13, "b": 255 },
        { "r": 12, "g": 13, "f": 13 }
      ]

      it 'should raise a TypeError', ->
        subject.should.be.an.instanceof(TypeError)
        subject.message.should.equal("Unrecognized attribute `f`")

      it 'should have no cause', ->
        should(subject.cause).be.null

      it 'should have the correct location', ->
        subject.location.should.equal('1')

    context 'with a wrong tuple attribute', ->
      arg = [
        { "r": 12, "g": 13, "b": 255  },
        { "r": 12, "g": 13, "b": 12.0 }
      ]
      subject = lambda(arg)

      it 'should raise a TypeError', ->
        subject.should.be.an.instanceof(TypeError)
        subject.message.should.equal("Invalid value `12.0` for Byte")

      it 'should have a cause', ->
        should(subject.cause).be.null

      it 'should have the correct location', ->
        subject.location.should.equal('1/b')

    context 'with a duplicate tuple', ->
      arg = [
        { "r": 12, "g": 13, "b": 255 },
        { "r": 12, "g": 192, "b": 13 },
        { "r": 12, "g": 13, "b": 255 }
      ]

      it 'should raise a TypeError', ->
        subject.should.be.an.instanceof(TypeError)
        subject.message.should.equal("Duplicate tuple")

      it 'should have no cause', ->
        should(subject.cause).be.null

      it 'should have the correct location', ->
        subject.location.should.equal('2')

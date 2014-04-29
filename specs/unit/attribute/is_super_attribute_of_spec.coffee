Attribute = require '../../../src/support/attribute'
should    = require 'should'
{intType, floatType, byteType} = require '../../spec_helpers'

describe "Attribute#isSuperAttributeOf", ->

  it 'recognizes if same', ->
    x = new Attribute('red', intType)
    y = new Attribute('red', intType)
    should(x.isSuperAttributeOf(y)).be.true

  it 'recognizes if subtype', ->
    x = new Attribute('red', intType)
    y = new Attribute('red', byteType)
    should(x.isSuperAttributeOf(y)).be.true

  it 'distinguishes if supertype', ->
    x = new Attribute('red', byteType)
    y = new Attribute('red', intType)
    should(x.isSuperAttributeOf(y)).be.false

  it 'distinguishes by name', ->
    x = new Attribute('red', intType)
    y = new Attribute('blue', intType)
    should(x.isSuperAttributeOf(y)).be.false

  it 'recognizes optional over required', ->
    x = new Attribute('red', intType, false)
    y = new Attribute('red', intType, true)
    should(x.isSuperAttributeOf(y)).be.true

  it 'distinguishes required over optional', ->
    x = new Attribute('red', intType, true)
    y = new Attribute('red', intType, false)
    should(x.isSuperAttributeOf(y)).be.false

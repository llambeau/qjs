Finitio  = require('../../../src/finitio')
System   = require('../../../src/finitio/system')
Relative = require('../../../src/finitio/resolver').Relative
should   = require('should')

describe "Resolver.Relative", ->

  world = Finitio.world(sourceUrl: 'file://specs/integration/fixtures/foo')

  it 'works with existing schemas', ->
    s = Relative('./test', world)
    should(s[0]).equal("file://specs/integration/fixtures/test")
    should(s[1]).not.be.an.instanceof(System)
    should(s[1].types).not.equal(undefined)

  it 'raises on unexisting file', ->
    lambda = ->
      Relative('./no-such-one', world)
    should(lambda).throw("No such file: `specs/integration/fixtures/no-such-one`")
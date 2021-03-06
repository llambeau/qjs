#!/usr/bin/env coffee
require('coffee-script')
Finitio = require('../src/finitio')
fs = require('fs')
program = require('commander');

program
  .version('finitio.js ' + Finitio.VERSION + ' (c) Bernard, Louis Lambeau & the University of Louvain')
  .usage('[options] SCHEMA.fio [DATA.json]')
  .option('-b, --bundle', 'Bundle the input schema as a javascript loader')
  .option('--url [url]', 'Specify the bundle global url')
  .option('-v, --validate', 'Valid input data against the schema')
  .option('-f, --fast', 'Stop on first validation error')
  .option('--no-check', 'Do not try to check the system before bundling')
  .option('--stack', 'Show stack trace on error')
  .parse(process.argv)

# Returns the sourceUrl
sourceUrl = ()->
  if typeof(program.url) is 'string'
    program.url
  else
    "file://" + program.args[0]

# Returns the schema file
schemaFile = ()->
  program.args[0]

# Loads the schema argument and returns its the source
schemaSource = ()->
  schemaFile = program.args[0]
  schemaSource = fs.readFileSync(schemaFile).toString()

world = ()->
  w = { sourceUrl: sourceUrl(), failfast: program.fast }
  if program.check
    w.check = true
  w

# Loads the schema argument and returns the compiled system
schema = ()->
  Finitio.system(schemaSource(), world())

# Loads the data arguments and returns it as a data object
data = ()->
  dataFile = program.args[1]
  dataSource = fs.readFileSync(dataFile).toString()
  JSON.parse(dataSource)

# Error management

strategies = []
errorManager = (e)->
  for s in strategies
    if s[0](e)
      s[1](e)
      break

strategies.push([
  (e)->
    e instanceof Finitio.TypeError
  (e)->
    if program.stack
      console.log(e.explainTree())
    else
      console.log(e.explain())
])

strategies.push([
  (e)->
    e.name == 'SyntaxError'
  (e)->
    console.log("[#{e.line}:#{e.column}] #{e.message}")
    console.log(e.expected) if program.stack
])

strategies.push([
  (e)->
    true
  (e)->
    console.log(e.message)
    console.log(e.stack) if program.stack
])

# Actions

actions = {}

# Compiles the schema and outputs it on standard output
actions.bundle = ()->
  console.log Finitio.bundleFile(schemaFile(), world())

# Validate input data using the schema
actions.validate = ()->
  console.log(schema().dress(data(), world()))

try
  if program.bundle
    action = actions.bundle
  else if program.validate
    action = actions.validate

  if action?
    action()
  else
    program.outputHelp()
catch e
  errorManager(e)
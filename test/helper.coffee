
# test/helper.coffee - Test initializer / helpers
module.exports = do ->

  _ = require 'underscore'
  chai = require 'chai'
  sinon = require 'sinon'

  SRC_FOLDER = unless process.env.COVER
    "../src/"
  else
    "../lib-cov/"


  chai.use require 'sinon-chai'
  chai.should() # infect Object.prototype

  return _.extend global or exports or this,
    source: (path) -> require "#{SRC_FOLDER}#{path}"
    log: console.log
    expect: chai.expect
    sinon: sinon



# test/test.coffee - Basic no-op tests to check that all build/test/compile tools works.
do ->

  describe 'Test environment', ->
    it 'should works', ->

    describe 'helper', ->
      before -> @helper = require './helper'
      after -> delete @helper

      it 'should inject functions into global', ->
        source.should.be.a 'function' # source function available globally



# test/test.coffee - Basic no-op tests to check that all build/test/compile tools works.
do ->

  describe 'Test environment', ->
    it 'should works', ->

    describe 'helper', ->
      before -> require './helper'

      it 'should be injected into global scope', ->
        source.should.be.a 'function' # works if source and should is added to global via ./helper



# test/beehive.coffee - Tests for the main beehive export.
do ->

  require './helper'


  describe 'Beehive module', ->
    before -> @beehive = source 'beehive'
    after -> delete @beehive

    it 'should loads', -> # no-op
    it 'should exports a function', ->
      @beehive.should.be.a 'function'

    it 'should exports the Hive class', ->
      @beehive.should.have.property 'Hive'
      @beehive.Hive.should.be.a 'function'

    it 'should exports the Bee class', ->
      @beehive.should.have.property 'Bee'
      @beehive.Bee.should.be.a 'function'

    describe 'createHive() method', ->
      before -> @create = @beehive.createHive
      after -> delete @create

      it 'should be exported', ->
        @create.should.be.a 'function'

      it 'should be aliased as createBeehive', ->
        @beehive.should.have.property 'createBeehive'
        @beehive.createBeehive.should.eq @create

      it 'should creates a new Hive', ->
        @create().should.be.instanceof @beehive.Hive


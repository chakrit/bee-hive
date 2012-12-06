
# test/hive.coffee - Tests the Hive processes container class.
module.exports = do ->

  { expect } = require './helper'

  _ = require 'underscore'
  a = require 'async'
  { exec } = require 'child_process'
  { EventEmitter } = require 'events'


  TAG = 'test-proc-1'
  TAG2 = 'test-proc-2'

  CMD_NAME = 'hive-test-process'
  CMD = "./test/#{CMD_NAME}"
  CMD2 = "./test/#{CMD_NAME} 0 random-text"


  # utils
  # HACK: Use constructor check with one-level deep prototype
  #   since we can't get child_process.ChildProcess class reference directly
  expectBee = (instance) ->
    ctor = instance.constructor
    ctor = ctor.toString() + ctor.prototype.constructor.toString()
    ctor.should.match /(Bee|ChildProcess)/i


  # interface
  describe 'Hive class', ->
    before -> @Hive = source 'hive'
    after -> delete @Hive

    it 'should exports a class', ->
      @Hive.should.be.a 'function'
      @Hive::.should.exists

    describe 'instances', ->
      before -> @hive = new @Hive
      after -> delete @hive

      # test template
      expectBadArgThrow = (methodName, args..., throwRegex) -> ->
        (=> this[methodName] args..., true).should.throw throwRegex
        (=> this[methodName] args..., 123).should.throw throwRegex
        (=> this[methodName] args..., { }).should.throw throwRegex

      it 'should be instanceof EventEmitter', ->
        @hive.should.be.instanceof EventEmitter
        @hive.should.respondTo 'removeAllListeners'

      it 'should exports a processes hash that is initially empty', ->
        @hive.should.have.property 'processes'
        _.keys(@hive.processes).should.have.length 0

      describe 'launch() method', ->
        before -> @launch = @hive.launch
        after -> delete @launch

        it 'should be exported', -> @launch.should.be.a 'function'

        it 'should complains if no arguments is given', ->
          (=> @launch()).should.throw()

        it 'should complains if cmd is not a string',
          expectBadArgThrow 'launch', /cmd/i

        it 'should complains if tag given but is not a string', ->
          (=> @launch true, CMD).should.throw /tag/
          (=> @launch { }, CMD).should.throw /tag/
          (=> @launch 123, CMD).should.throw /tag/

        it 'should complains if callback is not a function',
          expectBadArgThrow 'launch', TAG, CMD, /callback/i


      describe 'get() method', ->
        before -> @get = @hive.get
        after -> delete @get

        it 'should be exported', -> @get.should.be.a 'function'

        it 'should complains if tag not given', ->
          (=> @get()).should.throw /tag/

        it 'should complains if tag not a string',
          expectBadArgThrow 'get', /tag/i

      describe 'all() method', ->
        before -> @all = @hive.all
        after -> delete @all

        it 'should be exported', -> @all.should.be.a 'function'

      describe 'remove() method', ->
        before -> @remove = @hive.remove
        after -> delete @remove

        it 'should be exported', -> @remove.should.be.a 'function'

        it 'should complains if tag not given', ->
          (=> @remove()).should.throw /tag/i

        it 'should complains if tag not a string',
          expectBadArgThrow 'remove', /tag/i

      describe 'kill() method', ->
        before -> @kill = @hive.kill
        after -> delete @kill

        it 'should be exported', -> @kill.should.be.a 'function'

        it 'should complains if tag not given', ->
          (=> @kill()).should.throw /tag/i

        it 'should complains if tag not a string',
          expectBadArgThrow 'kill', /tag/i

        it 'should complains if signal given but not a string',
          expectBadArgThrow 'kill', TAG, /signal/i

      describe 'killall() method', ->
        before -> @killall = @hive.killall
        after -> delete @killall

        it 'should be exported', -> @killall.should.be.a 'function'

        it 'should complains if signal given but not a string',
          expectBadArgThrow 'killall', /signal/i


  # interactions
  describe 'Hive instances', ->
    beforeEach ->
      @Hive = source 'hive'
      @hive = new @Hive
    afterEach (done) ->
      delete @Hive
      delete @hive

      # cleanup test processes
      exec "killall -9 #{CMD_NAME}", (e, stdout, stderr) ->
        done() # ignores error

    it 'should be creatable', ->
      @hive.should.be.instanceof @Hive

    it 'should returns null for get() initially when there are no processes launched', ->
      expect(@hive.get TAG).to.be.null

    describe 'launching a process', ->
      beforeEach -> @launch = (cb) -> @hive.launch TAG, CMD, cb
      afterEach -> delete @launch

      it 'should calls back', (done) ->
        @launch done

      it 'should suceeeds', (done) ->
        @launch (e) ->
          return done e if e
          exec "ps aux", (e, stdout, stderr) ->
            return done e if e
            stdout.should.contain CMD_NAME
            done()

      it 'should emits a `launch` event with the same arguments', (done) ->
        @hive.once 'launch', (tag, cmd) ->
          tag.should.eq TAG
          cmd.should.eq CMD
          done()

        @launch (e) ->
          return done e if e

    describe 'with two launched processes', ->
      beforeEach (done) ->
        a.series [
          (next) => @hive.launch TAG, CMD, next
        , (next) => @hive.launch TAG2, CMD2, next
        ], (e) =>
          @proc1 = @hive.processes[TAG]
          @proc2 = @hive.processes[TAG2]
          stub @proc1, 'kill'
          stub @proc2, 'kill'
          done e


        # test template
        @expectTagsEql = (expectedTags...) =>
          tags = @hive.tags()
          tags.should.be.an 'array'
          tags.should.eql expectedTags

        @expectProcsEql = (expectedProcesses...) =>
          procs = @hive.all()
          procs.should.be.an 'array'
          procs.should.be.eql expectedProcesses

      afterEach ->
        @proc1.kill.restore()
        @proc2.kill.restore()
        delete @proc1
        delete @proc2
        delete @expectTagsEql
        delete @expectProcsEql


      it 'should set tag reference in processes property', ->
        @proc1.should.exists
        @proc2.should.exists

      it 'should save process object in processes property by tag', ->
        expectBee @proc1
        expectBee @proc2

      it 'should lists the tags in result when calling tags()', ->
        @expectTagsEql TAG, TAG2

      it 'should lists the processes in result when calling all()', ->
        @expectProcsEql @proc1, @proc2

      describe 'calling get() with the tags', ->
        beforeEach -> @get = @hive.get
        afterEach -> delete @get

        it 'should returns the correct tag for first process', ->
          expectBee @hive.get TAG

        it 'should returns the correct tag for second process', ->
          expectBee @hive.get TAG2

      describe 'calling remove() with the tags', ->
        beforeEach -> @remove = @hive.remove
        afterEach -> delete @remove

        it 'should no longer list the removed tags in result of tags()', ->
          @remove TAG2
          @expectTagsEql TAG

        it 'should no longer list the removed process in result of all()', ->
          @remove TAG
          @expectProcsEql @proc2

      describe 'calling kill() with tag', ->
        beforeEach ->
          @kill = @hive.kill
        afterEach ->
          delete @kill

        it 'should kills the tagged processes', ->
          @kill TAG
          @proc1.kill.should.have.been.called

        it 'should sends the given signal to the tagged process', ->
          @kill TAG2, 'SIGXXX'
          @proc2.kill.should.have.been.calledWith 'SIGXXX'

      describe 'calling killall()', ->
        beforeEach -> @killall = @hive.killall
        afterEach -> delete @killall

        it 'should kills all processes', ->
          @killall()
          @proc1.kill.should.have.been.called
          @proc2.kill.should.have.been.called

        it 'should sends the given signal to all processes', ->
          @killall 'SIGXXX'
          @proc1.kill.should.have.been.calledWith 'SIGXXX'
          @proc2.kill.should.have.been.calledWith 'SIGXXX'


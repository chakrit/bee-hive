
# test/bee.coffee - Test the bee process wrapper class
do ->

  { Stream } = require 'stream'
  { EventEmitter } = require 'events'
  { stub, TestStream } = require './helper'

  PROC = new class extends EventEmitter
    stdin: new TestStream
    stdout: new TestStream
    stderr: new TestStream

    kill: -> # for stubbing only

    reset: -> # make sure we unpipe all things after each test
      PROC.stdin.removeAllListeners()
      PROC.stdout.removeAllListeners()
      PROC.stderr.removeAllListeners()
      @removeAllListeners()


  describe 'Bee class', ->
    before -> @Bee = source 'bee'
    afterEach -> PROC.reset()
    after -> delete @Bee

    it 'should be exported', ->
      @Bee.should.be.a 'function'

    describe 'instantiation', ->
      before -> @create = (args...) => new @Bee args...
      after -> delete @create

      it 'should throws when creating without a child process', ->
        (=> @create()).should.throw /child/i

      it 'should throws when given something that does not looks like a child process', ->
        for arg in [true, { }, 123, '123']
          (=> @create arg).should.throw /child/i

      it 'should exports a state property which is initially `open`', ->
        bee = @create PROC
        bee.should.have.property 'state'
        bee.state.should.eq 'open'

      it 'should saves child instances in `proc` property', ->
        bee = @create PROC
        bee.should.have.property 'proc'
        bee.proc.should.eq PROC


      for fd in "out,err".split ',' then do (fd = "std#{fd}") ->
        it "should expose #{fd} property", ->
          (@create PROC).should.have.property fd

        it "should stream #{fd} from wrapped process.", (done) ->
          chunk = new Buffer 'hello!'
          bee = @create PROC

          bee[fd].once 'data', (chunk_) ->
            chunk_.should.eq chunk
            done()

          PROC[fd].emit 'data', chunk

      it 'should expose stdin property', ->
        (@create PROC).should.have.property 'stdin'

      it 'should forwards stdin from the bee to the wrapped process', (done) ->
        chunk = new Buffer 'bebeeeeeefefeee'
        bee = @create PROC

        PROC.stdin.once 'data', (chunk_) ->
          chunk_.should.eql chunk
          done()

        bee.stdin.write chunk

    describe 'instances', ->
      beforeEach -> @bee = new @Bee PROC
      afterEach -> delete @bee

      it 'should be instanceof EventEmitter', ->
        @bee.should.be.instanceof EventEmitter

      it 'should have an `open` state initially', ->
        @bee.state.should.eq 'open'

      it 'should changes to `close` state when the child process emits `close`', ->
        PROC.emit 'close'
        @bee.state.should.eq 'close'

      it 'should changes to `exit` state when the child process emits `exit`', ->
        PROC.emit 'exit'
        @bee.state.should.eq 'exit'

      it 'should emits `close` event when the child process emits `close`', (done) ->
        @bee.once 'close', done
        PROC.emit 'close'

      it 'should emits `exit` event when the child process emits `exit`', (done) ->
        @bee.once 'exit', done
        PROC.emit 'exit'

      describe 'kill() method', ->
        it 'should be exported', ->
          @bee.should.respondTo 'kill'

        it 'should kills the process with the supplied signal', ->
          stub PROC, 'kill'
          @bee.kill 'SIGTERM'
          PROC.kill.should.have.been.calledWith 'SIGTERM'
          PROC.kill.restore()


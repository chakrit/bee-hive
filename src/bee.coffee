
# src/bee.coffee - Bee (process wrapper)
module.exports = do ->

  { peek, PeekStream } = require 'peekstream'
  { EventEmitter } = require 'events'
  Stream = require 'stream'

  # Bee class - wraps a ChildProcess and provides
  #   stream snapshots and simple state property
  #   to easily check if the process has exited
  return class Bee extends EventEmitter
    stdin: null
    stdout: null
    stderr: null
    state: null

    constructor: (childProc) ->
      unless childProc and childProc.stdin
        throw new Error 'child process missing or not a ChildProcess'

      # WARN: Check circular references?
      #   Bee -> Stream -> 
      @proc = childProc
      @stdin = new PeekStream
      @stdin.pipe childProc.stdin

      @stdout = peek childProc.stdout
      @stderr = peek childProc.stderr

      @state = 'open'

      @proc.setMaxListeners 15
      @proc.on 'close', @handleClose
      @proc.on 'exit', @handleExit

    handleClose: =>
      @state = 'close'
      @emit 'close'

    handleExit: =>
      @state = 'exit'
      @emit 'exit'


    kill: (sig) =>
      @proc.kill sig


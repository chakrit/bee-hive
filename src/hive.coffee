
# src/hive.coffee - Hive processes manipulation class
module.exports = do ->

  { exec } = require 'child_process'
  { EventEmitter } = require 'events'
  { nextTick } = process

  Bee = require './bee'


  validateTag = (tag) ->
    unless typeof tag is 'string'
      throw new Error 'tag argument missing or not a string'

  validateSignal = (signal) ->
    unless typeof signal is 'string' or not signal
      throw new Error 'signal argument not a string'


  return class Hive extends EventEmitter
    constructor: ->
      super()
      @processes = Object.create null

    launch: (tag, cmd, cb) =>
      unless cb
        unless cmd
          cmd = tag
          cb = ->
        else if typeof cmd is 'function'
          cb = cmd
          cmd = tag
        else
          cb = ->

      throw new Error 'cmd argument missing or not a string' unless typeof cmd is 'string'
      throw new Error 'callback argument missing or not a function' unless typeof cb is 'function'
      validateTag tag

      @processes[tag] = child = new Bee exec cmd

      nextTick () =>
        child.tag = tag
        child.cmd = cmd

        @emit 'launch', tag, cmd, child
        cb()

    get: (tag) =>
      validateTag tag
      return @processes[tag] or null

    tags: =>
      return (tag for tag of @processes)

    all: =>
      return (proc for tag, proc of @processes)

    remove: (tag) =>
      validateTag tag
      delete @processes[tag]

    clear: =>
      @remove tag for tag of @processes

    kill: (tag, signal) =>
      validateTag tag
      validateSignal signal

      proc = @processes[tag]
      proc.kill signal

    killall: (signal) =>
      validateSignal signal
      proc.kill signal for tag, proc of @processes


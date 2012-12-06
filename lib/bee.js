// Generated by CoffeeScript 1.4.0
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = (function() {
  var Bee, EventEmitter, PeekStream, Stream, peek, _ref;
  _ref = require('peekstream'), peek = _ref.peek, PeekStream = _ref.PeekStream;
  EventEmitter = require('events').EventEmitter;
  Stream = require('stream');
  return Bee = (function(_super) {

    __extends(Bee, _super);

    Bee.prototype.stdin = null;

    Bee.prototype.stdout = null;

    Bee.prototype.stderr = null;

    Bee.prototype.state = null;

    function Bee(childProc) {
      this.kill = __bind(this.kill, this);

      this.handleExit = __bind(this.handleExit, this);

      this.handleClose = __bind(this.handleClose, this);
      if (!(childProc && childProc.stdin)) {
        throw new Error('child process missing or not a ChildProcess');
      }
      this.proc = childProc;
      this.stdin = new PeekStream;
      this.stdin.pipe(childProc.stdin);
      this.stdout = peek(childProc.stdout);
      this.stderr = peek(childProc.stderr);
      this.state = 'open';
      this.proc.setMaxListeners(15);
      this.proc.on('close', this.handleClose);
      this.proc.on('exit', this.handleExit);
    }

    Bee.prototype.handleClose = function() {
      this.state = 'close';
      return this.emit('close');
    };

    Bee.prototype.handleExit = function() {
      this.state = 'exit';
      return this.emit('exit');
    };

    Bee.prototype.kill = function(sig) {
      return this.proc.kill(sig);
    };

    return Bee;

  })(EventEmitter);
})();
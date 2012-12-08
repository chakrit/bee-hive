
# BEE-HIVE

The stupid dash in the name was because `beehive` is another package
I hadn't known existed before starting this. Yeah, lessons learned, thanks.

---

BEE-HIVE lets you launches, tag, monitor and manage multiple node.js ChildProcess(es) with ease.

Install and put in your package.json with:

```sh
$ npm install bee-hive --save
```

!!! Not to be confused with the `beehive` (without the dash) package !!!

# API

### new require('bee-hive').Hive() || require('bee-hive').createHive()

Creates a new `Hive` to manage your process.

### hive.launch( [tag], cmd )

Launch a process and give it a tag for later reference.

### hive.processes[ tag ] || hive.get( tag )

Gets the wrapped ChildProcess object from the hive.

### hive.tags()

Returns all the tags in the hive.

### hive.all()

Returns all the processes launched via the hive.

### hive.remove( tag )

Removes a tagged process from the hive. Does not kill the process.

### hive.clear()

Removes all processes from the hive. Does not kill any process.

### hive.kill( tag, [signal] )

Sends the tagged process the given kill signal.
Signal defaults to node's child.kill() defaults.

### hive.killall( [signal] )

Kill all processes in the hive with the given signal.

# EXTRAS

### require('bee-hive').Bee

Bee class, which is what is used by the hive to wrap node.js native
ChildProcess object.

### new Bee( childProc )

Wraps the given node.js native ChildProcess object.

### bee.stdin, bee.stdout, bee.stderr

Bee wraps ChildProcess's stdin, stdout and stderr in a
[`PeekStream`](https://github.com/chakrit/peekstream) which provides
a `window` property that has the last few bytes that was emitted
from the stream.

Very handy for logging and instrospection. i.e. see the last few lines
from stderr when the process dies.

Otherwise the stream should behaves the same as any ChildProcess stream.

### bee.state

Bee listens for ChildProcess's `close` and `exit` event automatically
on wraps and will set this property to `close` and `exit` respectively
when the event happens.

A new bee should have an `open` state initially.

### bee.proc

The originally wrapped process.

# SEE ALSO

* peekstream` - which provides the windowing feature.

# LICENSE

BSD

# SUPPORT / CONTRIBUTE

Just ping me [@chakrit](http://twitter.com/chakrit) on twitter.
Or just file a [new GitHub issue](https://github.com/chakrit/peekstream/issues/new)

Pull requests also welcome! :)


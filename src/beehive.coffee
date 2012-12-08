
# src/beehive.coffee - Primary Beehive exports
module.exports = do ->

  Hive = require './hive'
  Bee = require './bee'

  beehive = (args...) -> new Hive args...

  beehive.createBeehive = beehive.createHive = beehive
  beehive.Hive = Hive
  beehive.Bee = Bee
  return beehive


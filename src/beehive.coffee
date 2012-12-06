
# src/beehive.coffee - Primary Beehive exports
module.exports = do ->

  Hive = require './hive'

  beehive = (args...) -> new Hive args...

  beehive.createBeehive = beehive
  beehive.Hive = Hive
  return beehive


kue = require "kue"

module.exports = jobs = kue.createQueue()

jobs.promote()

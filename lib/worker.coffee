jobs = require "./jobs"
Dreamnet = require "./scrapers/dreamnet"
Indexer = require "./indexer"

jobs.process "dreamnet", (job, done) ->
	Dreamnet.process job, done

jobs.process "indexapp", (job, done) ->
	Indexer.index job, done

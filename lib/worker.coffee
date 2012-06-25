jobs = require "./jobs"
Dreamnet = require "./scrapers/dreamnet"
Indexer = require "./indexer"
Cydia = require "./cydia"

jobs.process "dreamnet", (job, done) ->
	Dreamnet.process job, done

jobs.process "indexapp", (job, done) ->
	Indexer.index job, done

jobs.process "cydia", Cydia.processCrawl
jobs.process "cydia:repository", Cydia.processRepository

{wrapCallback} = util = require "./util"
jobs = require "./jobs"
iTunes = require "./itunes"

module.exports = Indexer = {}

Indexer.queue = (bundleId) ->
	job = jobs.create "indexapp", 
		title: "Index app '#{bundleId}'"
		bundleId: bundleId
	job.priority "high"
	job.save()

Indexer.index = (job, cb) ->
	# Let's first try resolving the bundleId from itunes, since that's easier
	# than Cydia.
	{bundleId} = job.data

	job.log "Checking iTunes first."
	iTunes.scrape bundleId, wrapCallback cb, (app) ->
		job.log "Found it in iTunes!"
		cb()

	# TODO: Cydia.

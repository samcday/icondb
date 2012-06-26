{wrapCallback} = util = require "./util"
jobs = require "./jobs"
iTunes = require "./itunes"
Cydia = require "./cydia"

App = require "./model/App"

module.exports = Indexer = {}

Indexer.queueDiscover = (bundleId) ->
	job = jobs.create "indexapp", 
		title: "Index app '#{bundleId}'"
		bundleId: bundleId
	job.priority "high"
	job.save()

Indexer.processDiscover = (job, cb) ->
	{bundleId} = job.data

	App.findOne { bundleId: bundleId }, wrapCallback cb, (app) ->
		return cb new Error "#{bundleId} is already discovered!" unless app.type is "unknown"

		Cydia.isCydiaApp bundleId, wrapCallback cb, (repo) ->
			if repo
				job.log "Found app in Cydia!"
				app.type = "cydia"
				app.cydia.repository = repo
				app.save wrapCallback cb, -> cb()
				return

			iTunes.lookupByBundleId bundleId, wrapCallback cb, (itunesData) ->
				if itunesData
					app.type = "itunes"
					app.itunes.id = itunesData.trackId
					app.name = itunesData.trackName
					app.latestVersion = itunesData.version
					app.save wrapCallback cb, -> cb()
					return

				cb new Error "Couldn't identify app."

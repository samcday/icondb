request = require "request"
async = require "async"
mongoose = require "./mongoose"
App = require "./model/App"
Bundle = require "./model/Bundle"
log = require "./log"
{wrapCallback} = util = require "./util"

module.exports = iTunes = {}

iTunes.scrape = (bundleId, cb) ->
	async.parallel
		itunes: (cb) ->
			request.get
				url: "http://itunes.apple.com/lookup"
				qs:
					bundleId: bundleId
			, (err, resp, body) ->
				return cb err if err?
				body = util.safeJSONParse body, cb
				unless body.resultCount is 1
					return cb new Error "Bundle #{bundleId} not found in iTunes"
				cb null, body.results[0]
		app: (cb) ->
			App.findOne()
				.where("bundleId", bundleId)
				.where("type", "itunes")
				.populate("latestBundle")
				.exec cb
	, wrapCallback cb, (results) ->
		{app, itunes} = results
		app = new App unless app?

		app.bundleId ?= itunes.bundleId
		app.type ?= "itunes"
		app.iTunesID ?= itunes.trackId
		app.icon = itunes.artworkUrl60

		app.save wrapCallback cb, ->
			# Find the bundle for the latest version.
			Bundle.findOne()
				.where("app", app._id)
				.where("version", itunes.version)
				.exec wrapCallback cb, (bundle) ->
					bundle = new Bundle unless bundle
					bundle.app ?= app._id
					bundle.version ?= itunes.version
					bundle.name = itunes.trackName
					bundle.save wrapCallback cb, ->
						app.latestBundle = bundle
						console.log app.latestBundle
						app.save wrapCallback cb, ->
							cb null, app

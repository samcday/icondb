request = require "request"
async = require "async"
moment = require "moment"
{GridStore} = mongodb = require "mongodb"
{wrapCallback} = util = require "./util"
mongoose = require "./mongoose"
App = require "./model/App"
Version = require "./model/Version"
log = require "./log"

module.exports = iTunes = {}

saveIcon = (app, iconUrl, cb) ->
	new GridStore(mongoose.connection.db, "#{app._id}_icon.png", "w").open wrapCallback cb, (gs) ->

itunesLookup = (bundleId, cb) ->
	request.get
		url: "http://itunes.apple.com/lookup"
		qs:
			bundleId: bundleId
	, wrapCallback cb, (resp, body) ->
		body = util.safeJSONParse body, cb
		unless body.resultCount is 1
			return cb new Error "Bundle #{bundleId} not found in iTunes"
		cb null, body.results[0]

iTunes.scrape = (bundleId, cb) ->
	App.findOne()
		.where("bundleId", bundleId)
		.populate("latestVersion")
		.exec wrapCallback cb, (app) ->
			return cb new Error "Wtf?" unless not app or app.type is "itunes"
			if app?.itunes?.lastScrape?
				if moment(app.itunes.lastScrape).diff(moment(), "days", true) < 1
					return cb new Error "Already scraped in the last 24 hours."
			app ?= new App

			itunesLookup bundleId, wrapCallback cb, (itunes) ->
				app.bundleId ?= itunes.bundleId
				app.type = "itunes"
				app.itunes.id ?= itunes.trackId
				app.itunes.lastScrape = new Date()
				app.itunes.data = JSON.stringify itunes
				app.icon = itunes.artworkUrl60

				app.save wrapCallback cb, ->
					# Find the latest version.
					Version.findOne()
						.where("app", app._id)
						.where("version", itunes.version)
						.exec wrapCallback cb, (version) ->
							version = new Version unless version
							version.app ?= app._id
							version.version ?= itunes.version
							version.name = itunes.trackName
							version.save wrapCallback cb, ->
								app.latestVersion = version
								app.save wrapCallback cb, ->
									cb null, app
																
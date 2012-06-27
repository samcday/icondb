request = require "request"
async = require "async"
moment = require "moment"
{wrapCallback} = util = require "./util"
mongoose = require "./mongoose"
App = require "./model/App"
log = require "./log"

module.exports = iTunes = {}

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
		.exec wrapCallback cb, (app) ->
			return cb new Error "iTunes scrape request on invalid app type." if app and not (app.type is "itunes" or app.type is "unknown")
			if app.itunes.lastScrape
				if moment(app.itunes.lastScrape).diff(moment(), "days", true) < 1
					return cb new Error "Already scraped in the last 24 hours."

			itunesLookup bundleId, wrapCallback cb, (itunes) ->
				app.bundleId ?= itunes.bundleId
				app.itunes.id ?= itunes.trackId
				app.itunes.lastScrape = new Date()
				app.type = "itunes"
				app.name = itunes.trackName
				app.icon = itunes.artworkUrl60
				app.latestVersion = itunes.version

				app.save wrapCallback cb, ->
					cb null, app

iTunes.discoverBundleId = (bundleId, cb) ->
	request.get
		url: "http://itunes.apple.com/lookup"
		qs:
			bundleId: bundleId
	, wrapCallback cb, (resp, body) ->
		body = util.safeJSONParse body, cb
		return cb() unless body.resultCount is 1
		cb null, body.results[0]

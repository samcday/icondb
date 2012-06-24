_ = require "underscore"
async = require "async"
request = require "request"
{EventEmitter} = require "events"
{qweryify, wrapCallback} = util = require "../util"
redis = require "../redis"
log = require "../log"
indexer = require "../indexer"
jobs = require "../jobs"

App = require "../model/App"
User = require "../model/User"

appIndexUrl	= "http://glasklarthd.dreamnet.at/app_index.php"
appIconUrl 	= "http://glasklarthd.dreamnet.at/theicons/%d/icon1/%s"

createIcon = (app, iconName, job, cb) ->
	return cb() if not app
	job.log "Downloading icon for #{bundleId}"
	

processApp = (task, cb) ->
	{bundleId, iconName, job} = task

	# Quick check to make sure we haven't scraped this bundle id from this site already.
	redis.sismember "dreamnet:scraped", bundleId, wrapCallback cb, (isMember) ->
		if isMember
			job.log "Skipping #{bundleId} as we already have it."
			return cb()
		App.findOrCreate bundleId, wrapCallback cb, (app) ->
			app.iconHints iphoneRetina: iconName, wrapCallback cb, ->
				createIcon app, iconName, job, cb

createGKIUser = (cb) ->
	User.findOne { username: "GKI" }, wrapCallback cb, (user) ->
		return cb null, user if user
		user = new User()
		user.username = "GKI"
		user.save wrapCallback cb, ->
			cb null, user

processQ = async.queue processApp, 5

module.exports = Dreamnet = {}

Dreamnet.queue = ->
	log.info "[dreamnet] Queuing scrape."
	job = jobs.create "dreamnet", title: "glasklarthd.dreamnet.at scrape"
	job.save()

Dreamnet.process = (job, cb) ->
	createGKIUser wrapCallback cb, (user) ->
		job.gki = user

		job.log "Downloading app index."
		request.get appIndexUrl, wrapCallback cb, (response, body) ->
			job.log "App index downloaded. #{body.length} bytes. DOMming it up."

			qweryify body, wrapCallback cb, (window) ->
				appRows = window.qwery("div#boxcontent > div").slice(1)
				done = 0
				total = appRows.length
				job.log "#{total} icons found."
				for appRow in appRows
					appCells = window.qwery "span", appRow
					[bundleId, iconName] = (cell.innerHTML.trim() for cell in appCells).slice(1)

					processQ.push { bundleId: bundleId, iconName: iconName, job: job }, (err) ->
						done++
						job.progress done, total
				processQ.drain = cb
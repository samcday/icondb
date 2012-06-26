_ = require "underscore"
async = require "async"
request = require "request"
{EventEmitter} = require "events"
{qweryify, wrapCallback} = util = require "../util"
redis = require "../redis"
log = require "../log"
indexer = require "../indexer"
jobs = require "../jobs"
Icons = require "../icons"

App = require "../model/App"
User = require "../model/User"

appIndexUrl	= "http://glasklarthd.dreamnet.at/app_index.php"
appIconUrl 	= "http://glasklarthd.dreamnet.at/theicons/%d/icon1/%s"
idRegex = /index\.php\?id\=([0-9]+)/

parseId = (url) ->
	matches = idRegex.exec url
	return null unless matches and matches.length > 1
	return parseInt matches[1]

createIcon = (app, user, siteId, iconName, job, cb) ->
	return cb() if not app
	iconReq = request.get util.format appIconUrl, siteId, iconName
	iconReq.on "response", (response) ->
		return cb new Error "Couldn't download icon for #{app.bundleId}" unless response.statusCode is 200
		Icons.new iconReq, app, user, wrapCallback cb, ->
			job.log "Successfully grabbed icon for #{bundleId}"
			redis.sadd "dreamnet:scraped", app.bundleId, cb

processApp = (task, cb) ->
	{bundleId, iconName, siteId, user, job} = task

	# Quick check to make sure we haven't scraped this bundle id from this site already.
	redis.sismember "dreamnet:scraped", bundleId, wrapCallback cb, (isMember) ->
		if isMember
			return cb()
		App.findOrCreate bundleId, wrapCallback cb, (app) ->
			app.iconHints { iphoneRetina: iconName }, wrapCallback cb, ->
				createIcon app, user, siteId, iconName, job, cb

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
		job.log "Downloading app index."
		request.get appIndexUrl, wrapCallback cb, (response, body) ->
			job.log "App index downloaded. #{body.length} bytes. DOMming it up."

			qweryify body, wrapCallback cb, (window) ->
				appRows = window.qwery("div#boxcontent > div").slice(1)
				done = 0
				total = appRows.length
				job.log "#{total} icons found."
				for appRow in appRows
					do (appRow) ->
						appCells = window.qwery "span", appRow
						[bundleId, iconName] = (cell.innerHTML.trim() for cell in appCells).slice(1)
						appLink = (window.qwery "a", appCells[0])[0].getAttribute "href"
						siteId = parseId appLink

						return job.log "WARNING: Couldn't determine ID # for #{bundleId}" unless siteId

						processQ.push { siteId: siteId, bundleId: bundleId, iconName: iconName, job: job, user: user}, (err) ->
							if err
								job.log "ERROR - Couldn't get icon for #{bundleId}: #{err.message}"
							done++
							job.progress done, total
				processQ.drain = cb

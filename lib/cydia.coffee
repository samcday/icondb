_ = require "underscore"
url = require "url"
request = require "request"
async = require "async"
{wrapCallback} = util = require "./util"
jobs = require "./jobs"
log = require "./log"

CydiaRepository = require "./model/CydiaRepository"

module.exports = Cydia = {}

indexLineRegex = /(.+?)\:\s?(.*)/

parseIndexFile = (raw) ->
	lines = _.compact raw.trim().split "\n"
	obj = {}
	prevKey = ""
	for line in lines
		if line[0] is " "
			obj[prevKey] += line
			continue
		matches = indexLineRegex.exec line
		continue unless matches
		[key, value] = matches.slice 1
		prevKey = key
		obj[key] = value
	return obj

Cydia.queueCrawl = ->
	log.info "[cydia] Queuing crawl."
	job = jobs.create "cydia", title: "Cydia crawl"
	job.save()

Cydia.queueRepository = (repo) ->
	log.info "[cydia] Queuing crawl of repository #{repo.url}."
	job = jobs.create "cydia", title: "Cydia repository crawl (#{repo.url})", repo: repo._id
	job.save()
	return job

getRelease = (repo, cb) ->
	releaseUrl = repo.url
	unless repo.distribution is "./"
		releaseUrl = url.resolve releaseUrl, "dists/#{repo.distribution}/"
	releaseUrl = url.resolve releaseUrl, "Release"

	request.get releaseUrl, (err, resp, body) ->
		return cb() unless resp.statusCode is 200
		cb null, parseIndexFile body

Cydia.processRepository = (job, cb) ->
	CydiaRepository.findById job.data.repo, wrapCallback cb, (repo) ->
		return cb new Error "Couldn't find Repository!" unless repo

		async.parallel 
			release: (cb) -> getRelease repo, cb
			packages: (cb) -> getPackages repo, cb
		, (err, results) ->
			

Cydia.processCrawl = (job, cb) ->
	CydiaRepository.find {}, wrapCallback cb, (repos) ->
		repoProgress = []
		updateProgress = ->
			sum = _.reduce repoProgress, ((memo, num) -> memo + num), 0
			job.progress sum, repoProgress.length * 100

		for repo in repos
			do (repo) ->
				repoProgress[repo._id] = 0

				repoJob = Cydia.queueRepository repo
				repoJob.on "progress", (progress) ->
					repoProgress[repo._id] = progress
					updateProgress()

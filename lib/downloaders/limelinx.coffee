_ = require "underscore"
jsdom = require "jsdom"
request = require "request"
{wrapCallback, qweryify} = util = require "../util"
log = require "../log"

module.exports = (url, cb) ->
	jar = request.jar()
	log.info "[limelinx] Downloading #{url}..."

	pageReq = request.get url, 
		jar: jar
		followRedirect: false
	, wrapCallback cb, (resp, body) ->
		return new Error "Invalid URL #{url} returned HTTP status #{resp.statusCode}" unless resp.statusCode is 200

		log.verbose "[limelinx] Snooping around #{url} for download link."
		qweryify body, wrapCallback cb, (window) ->
			link = _.first window.qwery "li#DownloadLI a"
			log.info "[limelinx] Found download URL #{link.href} for download page #{url}!"

			downloadReq = request.get link.href, 
				jar: jar
			downloadReq.once "error", cb
			downloadReq.on "response", (resp) ->
				downloadReq.removeListener "error", cb
				return cb new Error "Download failed." unless resp.statusCode is 200
				downloadReq.pause()
				cb null, resp, downloadReq

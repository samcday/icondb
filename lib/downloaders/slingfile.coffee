_ = require "underscore"
request = require "request"
{wrapCallback, qweryify} = util = require "../util"
log = require "../log"

module.exports = (url, cb) ->
	log.info "[slingfile] Getting #{url}..."
	jar = request.jar()

	# Hit the download page normally first to establish a session cookie.
	log.verbose "[slingfile] HEADing initial page for #{url} for auth."
	pageReq = request.head url,
		followRedirect: false
		jar: jar

	pageReq.once "response", (resp) ->
		log.silly "[slingfile] got response for HEAD #{url}", resp

		# If the file doesn't exist slingfile tries to 302 redirect us.
		return cb new Error "URL is no longer valid." unless resp.statusCode is 200

		# Now we post "download" to the same URL again.
		log.verbose "[slingfile] POSTing to #{url} for download page."
		downloadPageReq = request.post url,
			followRedirect: false
			jar: jar
			form: download: 1
		, wrapCallback cb, (resp, body) ->
			log.silly "[slingfile] Download page response for #{url}", resp
			return cb new Error "URL is no longer valid." unless resp.statusCode is 200

			log.verbose "[slingfile] scanning #{url} for download link..."
			qweryify body, wrapCallback cb, (window) ->
				link = _.first window.qwery "div#boxsuccess a"
				return cb new Error "Couldn't find download link." unless link
				
				log.info "[slingfile] Found download URL #{link.href} for download URL #{url}"

				downloadReq = request.get link.href, 
					jar: jar

				downloadReq.on "error", cb
				downloadReq.on "response", (resp) ->
					return cb new Error "Download failed." unless resp.statusCode is 200
					downloadReq.pause()
					cb null, resp, downloadReq

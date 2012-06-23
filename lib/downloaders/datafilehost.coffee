request = require "request"

urlRegex = /^http\:\/\/www\.datafilehost\.com\/download\-([a-zA-Z0-9]+)\.html$/
downloadUrl = "http://www.datafilehost.com/get.php?file="

module.exports = (url, cb) ->
	matches = urlRegex.exec url
	return cb new Error "Invalid datafilehost URL: #{url}" unless matches
	[url, fileId] = matches

	jar = request.jar()
	# First request is to snag a session ID from dfh.
	authReq = request.get url,
		jar: jar
	authReq.on "response", (response) ->
		dlReq = request.get "#{downloadUrl}#{fileId}",
			headers:
				referer: url
			jar: jar
		dlReq.once "error", cb
		dlReq.once "response", (resp) ->
			dlReq.removeListener "error", cb
			dlReq.pause()
			return cb new Error "Download error" unless resp.headers["content-type"] is "application/octet-stream"
			return cb new Error "Download error" unless resp.headers["content-type"] is "application/octet-stream"
			cb null, resp, dlReq

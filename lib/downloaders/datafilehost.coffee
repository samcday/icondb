request = require "request"

urlRegex = /^http\:\/\/www\.datafilehost\.com\/download\-([a-zA-Z0-9]+)\.html$/
downloadUrl = "http://www.datafilehost.com/get.php?file="

module.exports = (url, cb) ->
	matches = urlRegex.exec url
	return cb new Error "Invalid datafilehost URL: #{url}" unless matches
	[url, fileId] = matches

	jar = request.jar()
	# First request is to snag a session ID from dfh.
	r = request.get url,
		jar: jar
	r.on "response", (response) ->
		cb null, request.get "#{downloadUrl}#{fileId}",
			headers:
				referer: url
			jar: jar

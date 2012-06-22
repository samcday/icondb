jsdom = require "jsdom"
request = require "request"
{wrapCallback} = util = require "../util"
log = require "../log"

module.exports = (url, cb) ->
	jar = request.jar()
	log.info "[limelinx] Downloading #{url}..."
	pageReq = request.get url, wrapCallback cb, (resp, body) ->
		return new Error "Invalid URL #{url} returned HTTP status #{resp.statusCode}" unless resp.statusCode is 200
		jsdom.env body, (err, win) ->
			console.log win
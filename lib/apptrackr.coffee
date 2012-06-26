request = require "request"

module.exports = Apptrackr = 
	link: {}
	app: {}

Apptrackr.request = (object, action, args, cb) ->
	req = 
		object: object
		action: action
		args: args
	payload = request: JSON.stringify req

	request.post
		url: "http://api.apptrackr.org/"
		form:
			request: JSON.stringify payload
	, (err, resp, body) ->
		body = JSON.parse body
		return cb new Error "API returned #{body.code} response." if body.code < 200 or body.code >= 300 
		data = JSON.parse body.data
		cb null, data

Apptrackr.link.get = (appId, cb) ->
	Apptrackr.request "Link", "get", { app_id: appId }, cb

Apptrackr.link.getAll = (appId, cb) ->
	Apptrackr.request "Link", "get", { app_id: appId, all_versions: true }, cb

Apptrackr.app.details = (appId, fields, cb) ->
	Apptrackr.request "App", "getDetails", 
		app_id: appId
		fields: fields
	, cb

Apptrackr.app.scrape = (itunesUrl, cb) ->
	Apptrackr.request "App", "scrape", { itunes_url: itunesUrl }, cb

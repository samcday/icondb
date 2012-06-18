request = require "request"

module.exports = Apptrackr = 
	link: {}

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
		console.log body

Apptrackr.link.get = (appId, cb) ->
	Apptrackr.request "Link", "get", { app_id: 310749044 }

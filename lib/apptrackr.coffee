request = require "request"
crypto = require "crypto"

publicKey = """
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxyZS+9iSODM7uiv4g1CNV36xg
zHsEgZaFxcy88BibdUxAEFwr0CgCy1TrnTMe87PmAElCmatPpGUSYmFQtM7YEsPf
UNfB/8q/dEeHXAH2I93PGN3wdLicY9K2SOz6GbkAkoEnpGSYwOKIBBsKi4/wZ33W
UcFkpmqMMlaiSc0zjwIDAQAB
-----END PUBLIC KEY-----
"""



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
		console.log body

Apptrackr.link.get = (appId, cb) ->
	Apptrackr.request "Link", "get", { app_id: appId }

Apptrackr.app.details = (appId, fields, cb) ->
	Apptrackr.request "App", "getDetails", 
		app_id: appId
		fields: fields

Apptrackr.app.scrape = (itunesUrl, cb) ->
	Apptrackr.request "App", "scrape", { itunes_url: itunesUrl }

{EventEmitter} = require "events"
request = require "request"
async = require "async"
xml2js = require "xml2js"
hash = require "node_hash"
config = require("../config").sendspace
log = require "../log"
{wrapCallback} = util = require "../util"

xmlParser = new xml2js.Parser()

module.exports = Sendspace = {}

session = new EventEmitter
sessionKey = null
sessionTimer = null

isPublicCall = (method) ->
	return /^auth\.(?!checksession|logout)/.test method

q = async.queue (task, cb) ->
	{method, params} = task

	doCall = ->
		log.debug "[sendspace] call: #{method}", params
		params.session_key = sessionKey if not isPublicCall method
		params.method = method
		request.get
			url: config.base
			qs: params
		, wrapCallback cb, (resp, body) ->
			xmlParser.parseString body, wrapCallback cb, (xml) ->
				if xml["@"].status is "fail"
					{code, text, info} = xml.error["@"]
					error = new Error "Sendspace API error: #{text}"
					error.code = code
					error.info = info
					return cb error
				cb null, xml
	if sessionKey is null and not isPublicCall method
		session.once "loggedin", ->
			doCall()
	else
		doCall()

q.concurrency = 2

sessionValid = (cb) ->
	doLogin = ->
		sessionKey = null
		loggedIn = -> return sessionKey isnt null
		async.until loggedIn, (cb) ->
			console.log()
		, cb
	return doLogin() unless sessionKey

checkSession = (cb) ->
	log.info "[sendspace] Checking if session is still valid."
	call "auth.checksession", { session_key: sessionKey }, (err, response) ->
		if err and err.code is 6
			login cb
		cb()

startSession = (_sessionKey) ->
	log.info "[sendspace] Logged in. session_key = #{_sessionKey}"
	sessionKey = _sessionKey
	session.emit "loggedin"
	# touchSession()

touchSession = ->
	# sessionTimer = setTimeout checkSession, config.timeout * 1000 if sessionKey

call = (method, params, cb) ->
	###log.debug "[sendspace] call: #{method}", params
	touchSession()
	params.session_key = sessionKey if method.startsWith "auth."
	params.method = method
	request.get
		url: config.base
		qs: params
	, wrapCallback cb, (resp, body) ->
		xmlParser.parseString body, wrapCallback cb, (xml) ->
			if xml["@"].status is "fail"
				{code, text, info} = xml.error["@"]
				error = new Error "Sendspace API error: #{text}"
				error.code = code
				error.info = info
				return cb error
			cb null, xml
	###
	q.push { method: method, params: params }, cb

createToken = (cb) ->
	log.info "[sendspace] Creating an auth token."
	call "auth.createtoken", 
		api_key: config.apikey
		api_version: "1.0"
		app_version: "1.0"
		response_format: "xml"
	, wrapCallback cb, (response) ->
		cb null, response.token

login = (cb) ->
	log.info "[sendspace] Logging in."
	createToken wrapCallback cb, (token) ->
		tokenedPass = hash.md5(token + hash.md5(config.password))
		call "auth.login", 
			token: token
			user_name: config.username
			tokened_password: tokenedPass
		, wrapCallback cb, (response) ->
			startSession response.session_key
			cb null if cb?

login()

Sendspace.getDownload = (fileId, cb) ->
	call "download.getInfo", { file_id: fileId }, wrapCallback cb, (result) ->
		cb null, result.download["@"].url if cb

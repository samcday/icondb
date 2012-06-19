module.exports = util = require "util"

# Convenience method, attempts to parse JSON and calls cb with error if it fails
# otherwise it *returns* the parsed JSON object.
util.safeJSONParse = (str, cb) ->
	try
		return JSON.parse str
	catch err
		cb new Error "JSON parse error"

dummy = () ->
util.wrapCallback = (cb, next) ->
	return (err) ->
		return (cb || dummy) err if err?
		next.apply null, Array.prototype.slice.call arguments, 1
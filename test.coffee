# iTunes = require "./lib/itunes"

# iTunes.scrape "com.yelp.yelpiphone", (err, app) ->
	# console.log arguments

# request = require "request"
# hi = request.get "http://google.com.au"

# hi.on "response", -> console.log arguments
#hi.on "data", (data) -> console.log data

# Apptrackr = require "./lib/apptrackr"
# Apptrackr.link.getAll 343200656, (err, links) ->
# 	console.log require("util").inspect links, false, null
# Apptrackr.app.details 284882215, ["appid"], console.log

#Sendspace = require "./lib/downloaders/sendspace"

#Sendspace.getDownload "6j1u3v", (err, url) ->
#	console.log url


# require "./lib/ipa"

fs = require "fs"
datafilehost = require "./lib/downloaders/datafilehost"
datafilehost "http://www.datafilehost.com/download-1dc01e71.html", (err, stream) ->
	return console.error err if err?
	stream.pipe fs.createWriteStream "/tmp/test.ipa"
	stream.on "response", -> console.log arguments
	stream.on "data", (data) -> console.log data.length

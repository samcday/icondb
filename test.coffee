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

###
fs = require "fs"
datafilehost = require "./lib/downloaders/datafilehost"
datafilehost "http://www.datafilehost.com/download-1dc01e71.html", (err, response, stream) ->
	return console.error err if err?
	console.log response
	stream.pipe fs.createWriteStream "/tmp/test.ipa"
	stream.resume()

	downloaded = 0
	stream.on "data", (data) ->
		downloaded += data.length
		console.log ((downloaded / response.headers["content-length"]) * 100) + "%"
###

###limelinx = require "./lib/downloaders/limelinx"
limelinx "http://limelinx.com/files/9c417bf7c3d16eea43907cde3d8225bd", (err) ->
	console.log arguments###


###
$ = require "jquery"

console.time "blah"
foo = $(str).find "div#boxsuccess a"
console.log foo.attr "href"
console.timeEnd "blah"
return
###

fs = require "fs"
slingfile = require "./lib/downloaders/slingfile"
slingfile "http://www.slingfile.com/file/o8yG7ioGbm", (err, response, stream) ->
	return console.error err if err?
	console.log response
	stream.pipe fs.createWriteStream "/tmp/test.ipa"
	stream.resume()

	downloaded = 0
	stream.on "data", (data) ->
		downloaded += data.length
		console.log ((downloaded / response.headers["content-length"]) * 100) + "%"

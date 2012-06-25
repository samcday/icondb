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
###
limelinx = require "./lib/downloaders/limelinx"
fs = require "fs"
limelinx "http://limelinx.com/files/9c417bf7c3d16eea43907cde3d8225bd", (err, response, stream) ->
	return console.error err if err?
	console.log response
	stream.pipe fs.createWriteStream "/tmp/test.ipa"
	stream.resume()

	downloaded = 0
	stream.on "data", (data) ->
		downloaded += data.length
		console.log ((downloaded / response.headers["content-length"]) * 100) + "%"
###

###
$ = require "jquery"

console.time "blah"
foo = $(str).find "div#boxsuccess a"
console.log foo.attr "href"
console.timeEnd "blah"
return
###

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
###
###
dreamnet = require "./lib/scrapers/dreamnet.coffee"
# dreamnet.queue()

job = {
	progress: (done, total) -> console.warn "progress #{done}/#{total}"
	log: (msg) -> console.log "#{msg}"
}

dreamnet.process job, ->
	console.log arguments
###
###
worker = require "./lib/worker"
Indexer = require "./lib/indexer"

#Indexer.queue "com.marvel.MarvelMobileComics", ->
#	console.log "Done!"
###
###
Indexer = require "./lib/indexer"
job = {
	progress: (done, total) -> console.warn "progress #{done}/#{total}"
	log: (msg) -> console.log "#{msg}"
	data:
		bundleId: "com.marvel.MarvelMobileComics"
}

Indexer.index job, (err) ->
	console.error err if err
	console.log "Done!"
###
###
App = require "./lib/model/App"

App.findOrCreate "com.foo.bar", ->
	console.log arguments
###
###
fs = require "fs"

#foo = fs.createReadStream "/tmp/test.png"
#foo = fs.createReadStream "/tmp/test.jpg"
foo = fs.createReadStream "/tmp/Qouch-v1.2.0-gers1978.ipa"	

{spawn} = require "child_process"

# proc = spawn "identify", ["-"]
proc = spawn "convert", ["-", "gif:-"]

#proc.stdout.setEncoding "utf8"
#proc.stdout.on "data", console.log
proc.stdout.on "data", -> console.log "omg! data!"
proc.stdout.pipe fs.createWriteStream "/tmp/out.gif"

proc.stderr.setEncoding "utf8"
proc.stderr.on "data", console.log

foo.pipe proc.stdin
foo.on "data", -> console.log "wrote"

proc.stdin.on "error", ->
	console.log "error", arguments

proc.on "exit", ->
	console.log arguments
###
###
foo = fs.createReadStream "/tmp/out.tiff"
proc = spawn "identify", ["-"]
proc.stdout.setEncoding "utf8"
proc.stdout.on "data", console.log
proc.stderr.setEncoding "utf8"
proc.stderr.on "data", console.log

totalBytes = 0
foo.pipe proc.stdin
foo.on "data", (data) ->
	totalBytes += data.length
	console.log totalBytes
###


###
mongoose = require "./lib/mongoose"
{GridStream} = GridFS = require "GridFS"

setTimeout ->
	s = GridStream.createGridWriteStream mongoose.connection.db, "foo", "w"

	s.write "hehehe"
	s.end()

	s.on "error", ->
		console.log arguments
	s.on "close", ->
		console.log arguments
, 1000
###
###
icons = require "./lib/icons"
fs = require "fs"

setTimeout ->
	# icons.new fs.createReadStream("/tmp/Icon.png"), null, null, ->
	icons.new fs.createReadStream("/tmp/Qouch-v1.2.0-gers1978.ipa"), null, null, ->
		console.log arguments
, 1000
###

util = require "./lib/util"
fs = require "fs"

bz2 = new util.bunzip2()

zzz = fs.createReadStream("/tmp/foo.html").pipe(bz2).pipe(process.stdout)

return 


job = {
	progress: (done, total) -> console.warn "progress #{done}/#{total}"
	log: (msg) -> console.log "#{msg}"
}


Cydia = require "./lib/cydia"
CydiaRepository = require "./lib/model/CydiaRepository"

job = {
	progress: (done, total) -> console.warn "progress #{done}/#{total}"
	log: (msg) -> console.log "#{msg}"
	data: repo: "4fe6faf8b261df4356000001"
}

Cydia.processRepository job,  ->
	console.log arguments






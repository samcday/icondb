crypto = require "crypto"
async = require "async"
{spawn} = child_process = require "child_process"
{GridStream} = GridFS = require "GridFS"
{GridStore} = mongodb = require "mongodb"
{WritableStreamBuffer} = require "stream-buffers"
{wrapCallback} = util = require "./util"
Icon = require "./model/Icon"
mongoose = require "./mongoose"

module.exports = Icons = {}

# Creates a new icon 
Icons.new = (incoming, app, user, cb) ->
	icon = new Icon
	icon.app = app
	icon.user = user

	gridFilename = "icon_#{icon._id}"

	# If anything goes wrong, this catchall cleanup will handle everyzink.
	cleanup = ->
		incoming.destroy()
		convert.kill()
		convert?.stdin?.destroy()
		convert?.stdout?.destroy()
		identify.kill()
		identify?.stdin?.destroy()
		identify?.stdout?.destroy()
		GridStore.unlink mongoose.connection.db, gridFilename, ->

	grid = GridStream.createGridWriteStream mongoose.connection.db, gridFilename, "w"

	# Hook up the convert to incoming data
	convert = spawn "convert", ["-", "png:-"]
	incoming.pipe convert.stdin

	# Setup hash obj and send convert output there.
	hash = crypto.createHash "sha1"
	convert.stdout.on "data", (data) -> hash.update data

	# Send convert output to gridstore too.
	convert.stdout.pipe grid

	# Hook up identify to incoming data.
	identifyOutput = new WritableStreamBuffer initialSize: 128
	identify = spawn "/bin/bash", ["-c", "identify -format \"%wx%h\" -"]
	incoming.pipe identify.stdin
	identify.stdout.pipe identifyOutput

	async.parallel 
		identify: (cb) ->
			identify.on "exit", (code) ->
				return cb new Error "Identify failed with error code #{code}" unless code is 0
				# Seems that "exit" can get called before stdout has finished flushing =\
				handleIdentify = ->
					dims = identifyOutput.getContentsAsString().trim()
					iconType = Icons.identify dims
					return cb new Error "Invalid icon type." if iconType is "unknown"
					return cb null, iconType

				if identify.stdout.destroyed then handleIdentify() else identify.stdout.once "end", handleIdentify
		convert: (cb) ->
			convert.on "exit", (code) ->
				return cb new Error "Convert failed with error code #{code}" unless code is 0
				handleConvert = ->
					cb null, hash.digest "base64"
				if convert.stdout.destroyed then handleConvert() else convert.stdout.once "end", handleConvert
	, (err, results) ->
		if err
			cleanup()
			return cb err
		grid.end()

		iconType = results.identify

		icon.type = iconType
		icon.hash = results.convert

		icon.save (err) ->
			if err
				cleanup()
				return cb err
			cb null, icon

Icons.identify = (dimensions) ->
	return switch dimensions
		when "57x57" then "iphone"
		when "114x114" then "iphoneRetina"
		when "72x72" then "ipad"
		when "144x144" then "ipadRetina"
		else "unknown"
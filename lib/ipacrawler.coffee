temp = require "temp"
glob = require "glob"
async = require "async"
path = require "path"
plist = require "plist"
im = require "imagemagick"
DeathByCaptcha = require "deathbycaptcha"
{exec} = child_process = require "child_process"
{wrapCallback} = util = require "./util"
Apptrackr = require "./apptrackr"

pngdefry = path.join __dirname, "..", "util", "pngdefry", "pngdefry"

unzip = (archive, cb) ->
	temp.mkdir "ipa", (err, tempPath) ->
		exec "/usr/bin/env unzip #{archive} -d #{tempPath}", wrapCallback cb, (stdout, stderr) ->
			cb null, tempPath

getAppPath = (path, cb) ->
	glob "#{path}/Payload/*.app/", wrapCallback cb, (matches) ->
		cb new Error "Ambiguous matches for app dir in IPA: #{matches}" unless matches.length is 1
		cb null, matches[0]

# This will handle cleaning up the bizarre optimizations done to pngs for iOS.
# Overwrites provided file.
fixIcon = (iconFile, cb) ->
	iconPath = path.dirname iconFile
	exec "#{pngdefry} -o #{iconPath} #{iconFile}", wrapCallback cb, (stdout, stderr) ->
		cb null

getPlist = (appPath, cb) ->
	plistFile = path.join appPath, "Info.plist"
	exec "/usr/bin/env plutil -i #{plistFile}", wrapCallback cb, (stdout, stderr) ->
		plist.parseString stdout, wrapCallback cb, (plist) ->
			cb null, plist[0]

parseIPA = (ipaFile, cb) ->
	async.waterfall [
		(cb) -> unzip ipaFile, cb
		(archivePath, cb) -> getAppPath archivePath, cb
	], (err, appPath) ->
		getPlist appPath, (err, plist) ->
			iconFile = path.join appPath, plist.CFBundleIconFile
			fixIcon iconFile, (err) ->
				im.identify iconFile, console.log
			#console.log arguments

parseIPA "/tmp/Qouch-v1.2.0-gers1978.ipa", () ->
	console.log arguments

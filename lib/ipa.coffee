_ = require "underscore"
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
log = require "./log"

defaultIconNames = ["icon.png", "Icon.png", "icon@2x.png", "Icon@2x.png",
		"icon-57.png", "Icon-57.png", "icon-72.png", "Icon-72.png",
		"icon-57@2x.png", "Icon-57@2x.png", "icon-72@2x.png", "Icon-72@2x.png"]

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

discoverIcons = (appPath, plist, cb) ->
	icons = [].concat defaultIconNames
	icons.push plist.CFBundleIconFile if plist.CFBundleIconFile
	icons = icons.concat plist.CFBundleIconFiles if plist.CFBundleIconFiles
	icons = _.union (path.join appPath, icon for icon in icons)
	async.filter icons, path.exists, (foundIcons) ->
		cb null, foundIcons

sortIcons = (icons, cb) ->
	sortedIcons = {}
	async.forEach icons, fixIcon, wrapCallback cb, ->
		async.map icons, im.identify, wrapCallback cb, (iconDims) ->
			for dim, i in iconDims
				icon = icons[i]
				dim = "#{dim.width}x#{dim.height}"
				switch dim
					when "57x57" then sortedIcons.iphone = icon
					when "114x114" then sortedIcons.retinaIphone = icon
					when "72x72" then sortedIcons.ipad = icon
					when "144x144" then sortedIcons.retinaIpad = icon
			cb null, sortedIcons

parseIPA = (ipaFile, cb) ->
	log.info "[ipa] Parsing #{ipaFile}"
	async.waterfall [
		(cb) -> unzip ipaFile, cb
		(archivePath, cb) -> getAppPath archivePath, cb
		(appPath, cb) -> getPlist appPath, wrapCallback cb, (plist) ->
			cb null, appPath, plist
	], wrapCallback cb, (appPath, plist) ->
		discoverIcons appPath, plist, wrapCallback cb, (icons) ->
			log.debug "[ipa] Discovered icons", icons
			sortIcons icons, (err, sortedIcons) ->
				console.log sortedIcons
		# iconFile = path.join appPath, plist.CFBundleIconFile
		# fixIcon iconFile, (err) ->
		# 		im.identify iconFile, console.log
		# 	#console.log arguments

parseIPA "/tmp/Qouch-v1.2.0-gers1978.ipa", () ->
	console.log arguments

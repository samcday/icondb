_ = require "underscore"
{Schema} = mongoose = require "../mongoose"
{wrapCallback} = util = require "../util"

VersionSchema = new Schema
	name:
		type: String
	version:
		type: String
	iconFiles:
		iphone: 
			type: String
		ipad:
			type: String
		iphoneRetina:
			type: String
		ipadRetina:
			type: String
	ipa:
		crawled:
			type: Boolean
		source:
			type: String
		date:
			type: Date
		plist:
			type: String

AppSchema = new Schema
	bundleId:
		type: String
		index: true
		unique: true
	type:
		type: String
		enum: ["cydia", "itunes", "system", "unknown"]
	versions: [VersionSchema]
	itunes:
		id:
			type: Number
		lastScrape:
			type: Date
		data:
			type: String
	apptrackr:
		lastScrape:
			type: Date
	cydia:
		repository:
			type: Schema.ObjectId
			ref: "CydiaRepository"

AppSchema.statics.findOrCreate = (bundleId, cb) ->
	app = new (this.model "App")
	app.bundleId = bundleId
	app.type = "unknown"
	app.versions.push {}
	app.save (err) =>
		if err
			# If the err.code is 11000, it just means the app already exists.
			return cb err unless err.code is 11000
			# We can just return it.
			return this.findOne { bundleId: bundleId }, cb

		# If there wasn't an error at all, it means we just created a new App.
		(require "../indexer").queue bundleId
		cb null, app

AppSchema.methods.findOrCreateVersion = (search, cb) ->
	version = _.find this.versions, (version) -> version.version is search
	if version then return process.nextTick -> cb null, version
	newVersion = { version: search }
	this.versions.push newVersion
	this.save wrapCallback cb, ->
		cb null, newVersion

AppSchema.methods.getLatestVersion = ->
	latest = null
	for version in this.versions
		latest = version if latest is null or latest.version.localeCompare(version.version) < 0
	return latest

AppSchema.methods.iconHints = (hints, cb) ->
	for version in this.versions
		_.defaults version.iconFiles, hints
	this.save cb

module.exports = mongoose.model "App", AppSchema

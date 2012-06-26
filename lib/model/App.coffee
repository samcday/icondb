_ = require "underscore"
{Schema} = mongoose = require "../mongoose"
{wrapCallback} = util = require "../util"

AppSchema = new Schema
	bundleId:
		type: String
		index: true
		unique: true
	type:
		type: String
		enum: ["cydia", "itunes", "system", "unknown"]
	name:
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
	latestVersion:
		type: String
	itunes:
		id:
			type: Number
		lastScrape:
			type: Date
	apptrackr:
		lastScrape:
			type: Date
	cydia:
		repository:
			type: Schema.ObjectId
			ref: "CydiaRepository"
	ipa:
		crawled:
			type: Boolean
		version:
			type: String
		source:
			type: String
		date:
			type: Date

AppSchema.statics.findOrCreate = (bundleId, cb) ->
	app = new (this.model "App")
	app.bundleId = bundleId
	app.type = "unknown"
	app.save (err) =>
		if err
			# If the err.code is 11000, it just means the app already exists.
			return cb err unless err.code is 11000
			# We can just return it.
			return this.findOne { bundleId: bundleId }, cb

		# If there wasn't an error at all, it means we just created a new App.
		(require "../indexer").queueDiscover bundleId
		cb null, app

AppSchema.methods.iconHints = (hints, cb) ->
	_.defaults this.iconFiles, hints
	this.save cb

module.exports = mongoose.model "App", AppSchema

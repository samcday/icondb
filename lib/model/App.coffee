{Schema} = mongoose = require "../mongoose"
Indexer = require "../indexer"

AppSchema = new Schema
	bundleId:
		type: String
		index: true
		unique: true
	type:
		type: String
		enum: ["cydia", "itunes", "system", "unknown"]
	latestVersion:
		type: Schema.ObjectId
		ref: "Version"
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

AppSchema.statics.findOrCreate = (bundleId, cb) ->
	app = new (this.model "App")
	app.bundleId = "com.foo.bar"
	app.type = "unknown"
	app.save (err) =>
		if err
			# If the err.code is 11000, it just means the app already exists.
			return cb err unless err.code is 11000
			# We can just return it.
			return this.findOne { bundleId: bundleId }, cb
		# If there wasnt' an error at all, it means we just created a new App.
		# Which means it's gonna need some serious indexing, yo.
		Indexer.queue bundleId
		cb null, app

module.exports = mongoose.model "App", AppSchema

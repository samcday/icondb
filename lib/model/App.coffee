mongoose = require "mongoose"
{Schema} = mongoose

AppSchema = new Schema
	bundleId:
		type: String
	type:
		type: String
		enum: ["cydia", "itunes", "system"]
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
		

module.exports = mongoose.model "App", AppSchema

{Schema} = mongoose = require "../mongoose"

VersionSchema = new Schema
	app:
		type: Schema.ObjectId
		ref: "App"
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

module.exports = mongoose.model "Version", VersionSchema

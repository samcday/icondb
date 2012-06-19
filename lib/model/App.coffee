mongoose = require "mongoose"
{Schema} = mongoose

AppSchema = new Schema
	bundleId:
		type: String
	type:
		type: String
		enum: ["cydia", "itunes", "system"]
	icon:
		type: String
	latestBundle:
		type: Schema.ObjectId
		ref: "Bundle"
	iTunesID:
		type: Number

module.exports = mongoose.model "App", AppSchema

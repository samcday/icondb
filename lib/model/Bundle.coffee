mongoose = require "mongoose"
{Schema} = mongoose

BundleSchema = new Schema
	app:
		type: Schema.ObjectId
		ref: "App"
	osType:
		type: String
		enum: ["ipad", "iphone", "universal"]
	name:
		type: String
	version:
		type: String
	iphoneIcon:
		type: String
	ipadIcon:
		type: String
	iphoneRetinaIcon:
		type: String
	ipadRetinaIcon:
		type: String

module.exports = mongoose.model "Bundle", BundleSchema

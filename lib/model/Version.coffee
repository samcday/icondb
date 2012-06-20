mongoose = require "mongoose"
{Schema} = mongoose

VersionSchema = new Schema
	app:
		type: Schema.ObjectId
		ref: "App"
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
	ipaCrawled:
		type: Boolean

module.exports = mongoose.model "Version", VersionSchema

{Schema} = mongoose = require "../mongoose"

IconSchema = new Schema
	app:
		type: Schema.ObjectId
		ref: "App"
	user:
		type: Schema.ObjectId
		ref: "User"
	type:
		type: String
		enum: ["iphone", "iphoneRetina", "ipad", "ipadRetina"]
	hash:
		type: String

module.exports = mongoose.model "Icon", IconSchema

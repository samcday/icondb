{Schema} = mongoose = require "../mongoose"

UserSchema = new Schema
	username:
		type: String
		required: true

module.exports = mongoose.model "User", UserSchema

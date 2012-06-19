module.exports = config = {}

config.sendspace =
	base: "http://api.sendspace.com/rest/"
	apikey: "Y2S7IHXXPZ"
	username: process.env.SENDSPACE_USER
	password: process.env.SENDSPACE_PASS
	timeout: 25 * 60
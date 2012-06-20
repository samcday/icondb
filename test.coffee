###
iTunes = require "./lib/itunes"

iTunes.scrape "com.yelp.yelpiphone", (err, app) ->
	console.log app
###

#Sendspace = require "./lib/downloaders/sendspace"

#Sendspace.getDownload "6j1u3v", (err, url) ->
#	console.log url


require "./lib/ipa"
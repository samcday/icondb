iTunes = require "./lib/itunes"

iTunes.scrape "com.yelp.yelpiphone", (err, app) ->
	console.log app
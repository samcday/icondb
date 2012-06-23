express = require "express"
kue = require "kue"

app = express.createServer()
app.use kue.app

app.listen 3000

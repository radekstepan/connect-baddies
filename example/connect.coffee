http    = require 'http'
connect = require 'connect'
middleware = require '../middleware'

app = connect()
.use(middleware())
.use (req, res) -> res.end 'Hello from Connect!'

http.createServer(app).listen 3000
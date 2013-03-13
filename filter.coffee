#!/usr/bin/env coffee
connect  = require 'connect'
flatiron = require 'flatiron'
request  = require 'request'

blacklist = require './blacklist.coffee'

# Traverse blacklist.
check = (input) ->
    # All that we want checking
    for name, field of input
        # Do we have rules?
        if groups = blacklist[name]
            for { fn, rules } in groups
                for rule in rules
                    if fn(field, rule) then return true

    # All good.
    false

# Cache the url/useragent pairs that have been processed already.
cache = {}
# Filter the request against a blacklist.
filter = (req, res, next) ->
    if check { 'useragent': req.headers['user-agent'], 'url': req.url }
        res.writeHead 403
        res.end 'You do not have permission to access this server'
    else
        next()

app = flatiron.app

app.use flatiron.plugins.http, 'before': [ filter ]

app.start 5200, (err) ->
    throw err if err
    
    # Make the request with some baddie inside.
    request
        'uri': 'http://127.0.0.1:5200'
        'headers': { 'user-agent': 'PussyCat' }
    , (err, res) ->
        console.log res.statusCode, res.body
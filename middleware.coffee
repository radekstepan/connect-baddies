#!/usr/bin/env coffee
blacklist = require './rules/blacklist.coffee'

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

# Filter the request against a blacklist.
module.exports = (req, res, next) ->
    if check { 'useragent': req.headers['user-agent'], 'url': req.url }
        res.writeHead 403
        res.end 'You do not have permission to access this server'
    else
        next()
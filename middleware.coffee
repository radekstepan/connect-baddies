#!/usr/bin/env coffee
blacklist = require './rules/blacklist.coffee'

# Traverse blacklist.
check = (input) ->
    # All that we want checking
    for name, field of input
        # Do we have rules?
        if groups = blacklist[name]
            for { fn, response, rules } in groups
                for rule in rules
                    if fn(field, rule) then return response

# Filter the request against a blacklist.
module.exports = (opts={}) ->
    (req, res, next) ->
        # Bad?
        if response = check { 'useragent': req.headers['user-agent'], 'url': req.url }
            # Log?
            if opts.log and typeof opts.log is 'function' then opts.log response.log
            # Respond.
            res.writeHead response.statusCode
            res.end response.message
        else
            next()
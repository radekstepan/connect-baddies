#!/usr/bin/env coffee
blacklist = require './rules/blacklist.coffee'

check = (req) ->
    # The request params.
    r =
        'useragent': req.headers['user-agent']
        'url':       req.url

    # Check the blacklist.
    for field, groups of blacklist
        if input = r[field]
            for { fn, response, rules } in groups
                for rule in rules
                    if fn(input, rule) then return response

# Filter the request or move along.
module.exports = (opts={}) ->
    (req, res, next) ->
        # Bad?
        if response = check req
            # Log?
            if opts.log and typeof opts.log is 'function' then opts.log response.log
            # Respond.
            res.writeHead response.statusCode
            res.end response.body
        else
            next()
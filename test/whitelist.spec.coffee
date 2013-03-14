#!/usr/bin/env coffee
{ assert } = require 'chai'
connect    = require 'connect'
http       = require 'http'
request    = require 'request'
RandExp    = require 'randexp'

middleware = require '../middleware.coffee'

app = connect()
.use(middleware())
.use (req, res) -> res.end 'Hello from Connect!'

port = null

# Get the whitelist rules.
whitelist = require '../rules/whitelist.coffee'

describe 'Whitelist', ->

    before (done) ->
        (server = http.createServer(app)).listen 0, ->
            port = server.address().port
            done()

    for field, rules of whitelist then do (field, rules) ->
        describe field, ->
            for rule in rules then do (rule) ->
                # Is rule a regular expression?
                if rule instanceof RegExp
                    # Generate a random variant.
                    rule = new RandExp(rule).gen()

                # Run the rule.
                it rule, (done) ->
                    # Expose the rule.
                    obj = 'useragent': '', 'url': '/'
                    obj[field] = rule

                    # Do we need to prefix url?
                    if obj.url[0] isnt '/' then obj.url = '/' + obj.url

                    # Make the call.
                    request
                        'url': "http://127.0.0.1:#{port}#{obj.url}"
                        'headers':
                            'user-agent': obj.useragent
                    , (err, res) ->
                        if err then return done err
                        if res.statusCode is 200 then return done()
                        else new Error res.body
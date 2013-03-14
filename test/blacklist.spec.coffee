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

# Get the blacklist rules.
blacklist = require '../rules/blacklist.coffee'

describe 'Blacklist', ->

    before (done) ->
        (server = http.createServer(app)).listen 0, ->
            port = server.address().port
            done()

    for field, groups of blacklist then do (field, groups) ->
        describe field, ->
            for { response, rules } in groups
                for i, rule of rules then do (rule) ->
                    # Is rule a regular expression?
                    if rule instanceof RegExp
                        # Generate a random variant.
                        rule = new RandExp(rule).gen()

                    # Run the rule.
                    it "##{i}: `#{rule}`", (done) ->
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
                            if res.statusCode is response.statusCode and
                                res.body is response.body
                                    return done()
                            done new Error res.body
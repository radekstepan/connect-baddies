#!/usr/bin/env coffee
{ assert } = require 'chai'
async      = require 'async'
flatiron   = require 'flatiron'
request    = require 'request'
RandExp    = require 'randexp'

middleware = require '../middleware.coffee'

# A flatiron app.
app = flatiron.app
app.use flatiron.plugins.http, 'before': [ middleware ]

port = null

# Get the blacklist rules.
blacklist = require '../rules/blacklist.coffee'

describe 'Blacklist', ->

    before (done) ->
        app.start 5200, (err) ->
            done err if err
            port = app.server.address().port
            done()

    for field, groups of blacklist then do (field, groups) ->
        describe field, ->
            for {rules} in groups
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
                            if res.statusCode is 403 then return done()
                            done new Error res.body
#!/usr/bin/env coffee

client = require "#{__dirname}/../index.coffee"

options =
  room: process.argv[2]

client.start options

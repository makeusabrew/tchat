#!/usr/bin/env coffee

client = require "#{__dirname}/../src/client"

options =
  room: process.argv[2]

client.start options

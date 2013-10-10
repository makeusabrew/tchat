#!/usr/bin/env coffee

# manually append '.coffee' otherwise index.js will win
client = require "#{__dirname}/../index.coffee"

options =
  room: process.argv[2]

client.start options

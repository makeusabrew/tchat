#!/usr/bin/env coffee

client = require "#{__dirname}/../index"

options =
  room: process.argv[2]

client.start options

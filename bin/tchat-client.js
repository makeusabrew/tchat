#!/usr/bin/env node
var client, options;

client = require(__dirname + "/../index");

options = {
  room: process.argv[2]
};

client.start(options);

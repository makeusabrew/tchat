net = require "net"

Server =
  start: (options) ->
    server = net.createServer()
    server.listen 9400

    server.on "listening", ->
      console.log "server listening"

    server.on "connection", ->
      console.log "got connection"

module.exports = Server

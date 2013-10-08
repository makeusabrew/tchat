require "colors"
net = require "net"

username = "test"

Client =
  start: ->
    options =
      port: 9400
      host: "localhost"

    connection = net.connect options

    connection.on "connect", ->
      console.log "connected OK"

    connection.on "error", ->
      console.log "error"

module.exports = Client

require "colors"
net = require "net"
SuperSocket = require "../shared/super_socket"

username = "test"

Client =
  start: (options = {}) ->

    socket = net.connect
      port: 9400
      host: "localhost"

    superSocket = new SuperSocket socket

    socket.on "connect", ->
      console.log "connected OK"

      if options.room
        # connect to existing room
        superSocket.write
          command: "join room"
          room: options.room
      else
        # @TODO obviously we'll wrap this properly at some point

        superSocket.write
          command: "create room"
          foo: "bar"

    superSocket.on "message", (data) ->
      console.log data.message

    socket.on "error", ->
      console.log "error"

module.exports = Client

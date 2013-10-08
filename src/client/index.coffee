require "colors"
net = require "net"

username = "test"

write = (socket, data) -> socket.write JSON.stringify data

Client =
  start: (options = {}) ->

    socket = net.connect
      port: 9400
      host: "localhost"

    socket.on "connect", ->
      console.log "connected OK"

      if options.room
        # connect to existing room
        write socket,
          command: "join room"
          room: options.room
      else
        # @TODO obviously we'll wrap this properly at some point

        write socket,
          command: "create room"
          foo: "bar"

    socket.on "data", (data) ->
      console.log data.toString "utf8"

    socket.on "error", ->
      console.log "error"

module.exports = Client

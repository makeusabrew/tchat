require "colors"
net = require "net"
Utils = require "../shared/utils"

username = "test"

Client =
  start: (options = {}) ->

    socket = net.connect
      port: 9400
      host: "localhost"

    socket.on "connect", ->
      console.log "connected OK"

      if options.room
        # connect to existing room
        Utils.write socket,
          command: "join room"
          room: options.room
      else
        # @TODO obviously we'll wrap this properly at some point

        Utils.write socket,
          command: "create room"
          foo: "bar"

    onCmd = Utils.createListener socket

    onCmd "message", (data) ->
      console.log data.message

    socket.on "error", ->
      console.log "error"

module.exports = Client

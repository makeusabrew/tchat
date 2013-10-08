require "colors"
net = require "net"
SuperSocket = require "../shared/super_socket"
tp = require "../../vendor/tidy-prompt/src/tidy-prompt"

Client =
  start: (options = {}) ->

    tp.start()

    socket = net.connect
      port: 9400
      host: "localhost"

    superSocket = new SuperSocket socket

    socket.on "connect", ->

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
      tp.log data.message

    socket.on "error", ->
      tp.log "error"

    tp.on "input", (data) ->
      superSocket.write
        command: "chat"
        message: data

module.exports = Client

tp.on "SIGINT", ->
  process.exit 0

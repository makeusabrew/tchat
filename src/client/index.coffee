require "colors"
net = require "net"
fs = require "fs"
SuperSocket = require "../shared/super_socket"
tp = require "../../vendor/tidy-prompt/src/tidy-prompt"

config = JSON.parse fs.readFileSync "#{process.env.HOME}/.tchat"

Client =
  start: (options = {}) ->

    tp.start()

    socket = net.connect
      port: 9400
      host: "localhost"

    superSocket = new SuperSocket socket

    socket.on "error", ->
      tp.log "error"

    socket.on "connect", ->

      # bear in mind this is just the initial TCP connection

      superSocket.write
        command: "auth"
        username: config.username

    superSocket.on "authed", ->

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

    superSocket.on "chat", (data) ->
      tp.log "#{data.user}: #{data.message}"

    tp.on "input", (data) ->
      superSocket.write
        command: "chat"
        message: data

module.exports = Client

tp.on "SIGINT", ->
  process.exit 0

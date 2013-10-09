require "colors"
net         = require "net"
fs          = require "fs"
SuperSocket = require "../shared/super_socket"
tp          = require "../../vendor/tidy-prompt/src/tidy-prompt"

configFile = "#{process.env.HOME}/.tchat"
config = if fs.existsSync configFile then JSON.parse fs.readFileSync configFile else {}

Client =
  start: (options = {}) ->

    tp.start()

    socket = net.connect
      port: 9400
      host: "localhost"

    # upgrade to our wrapper object which exposes a lot
    # of convenience methods
    superSocket = new SuperSocket socket

    #
    # base socket handlers
    #
    socket.on "error", ->
      tp.log "error"

    socket.on "connect", ->

      # bear in mind this is just the initial TCP connection
      # so the first thing we want to do is register our user

      superSocket.write
        command: "auth"
        username: config.username

    #
    # augmented socket handlers
    #
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

    #
    # user input handlers
    #
    tp.on "input", handleInput superSocket

    tp.on "SIGINT", ->
      process.exit 0

module.exports = Client

handleInput = (socket) ->
  return (data) ->
    switch data
      when "/status"
        socket.write command: "status"
      else
        socket.write
          command: "chat"
          message: data

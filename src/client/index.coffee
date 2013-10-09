require "colors"
net         = require "net"
fs          = require "fs"
SuperSocket = require "../shared/super_socket"
tp          = require "../../vendor/tidy-prompt/src/tidy-prompt"
config      = require "../shared/config"

configFile = "#{process.env.HOME}/.tchat"
userConfig = if fs.existsSync configFile then JSON.parse fs.readFileSync configFile else {}

config[k] = v for k,v of userConfig

connect = (options) ->

  tp.setInPrompt "#{config.username}: "

  tp.log "Connecting as #{config.username}"

  socket = net.connect
    port: config.port
    host: config.server

  # upgrade to our wrapper object which exposes a lot
  # of convenience methods
  superSocket = new SuperSocket socket

  #
  # base socket handlers
  #
  socket.on "error", ->
    tp.log "error connecting to server"
    process.exit 0

  socket.on "end", ->
    tp.log "server went away"
    process.exit 0

  socket.on "connect", ->

    # bear in mind this is just the initial TCP connection
    # so the first thing we want to do is register our user

    superSocket.write "auth", username: config.username

  #
  # augmented socket handlers
  #
  superSocket.on "authed", ->

    if options.room
      superSocket.write "join room", room: options.room
    else
      superSocket.write "create room"

  superSocket.on "message", (data) ->
    tp.log data.message

  superSocket.on "chat", (data) ->
    tp.log "#{data.user}: #{data.message}"

  superSocket.on "leave", (data) ->
    tp.log "#{data.user} left the room"

  #
  # user input handlers
  #
  tp.on "input", handleInput superSocket

  tp.on "SIGINT", ->
    process.exit 0

Client =
  start: (options = {}) ->

    tp.start()

    if not config.username
      tp.prompt "Please enter a username (you only have to do this once):", (username) ->
        config.username = username

        fs.writeFileSync configFile, JSON.stringify config, null, 2

        tp.log "Username saved to #{configFile}"
        tp.log "You can edit this file to alter various preferences"

        connect options
    else
      connect options

module.exports = Client

handleInput = (socket) ->
  return (data) ->
    switch data
      when "/status"
        socket.write "status"
      else
        socket.write "chat", message: data

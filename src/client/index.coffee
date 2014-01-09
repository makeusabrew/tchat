require "colors"
net         = require "net"
fs          = require "fs"
SuperSocket = require "../shared/super_socket"
tp          = if process.env.NODE_ENV isnt "build" then require "tidy-prompt" else require "#{__dirname}/../../../tidy-prompt/index.coffee"
config      = require "../shared/config"

configFile = "#{process.env.HOME}/.tchat"
userConfig = if fs.existsSync configFile then JSON.parse fs.readFileSync configFile else {}

config[k] = v for k,v of userConfig

connect = (options) ->

  tp.setInPrompt "#{config.username}: "

  tp.log "Connecting to #{config.host}:#{config.port}... "

  socket = net.connect
    port: config.port
    host: config.host

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

    tp.log "Authenticating as #{config.username}..."

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
  tp.on "data", (char, next) -> next char

  tp.on "input", (data, fulfil) ->
    switch data
      when "/status"
        superSocket.write "status"
        tp.clearLine()
      else
        superSocket.write "chat", message: data
        fulfil data

  tp.on "SIGINT", ->
    process.exit 0

Client =
  start: (options = {}) ->

    tp.start
      trapLine: true

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

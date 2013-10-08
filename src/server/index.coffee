net = require "net"

# currently active rooms
rooms = {}

# possible room keys/names
roomKeys = [
  "a", "b", "c"
]

# active connections
connections = []

Server =
  start: (options) ->
    server = net.createServer()
    server.listen 9400

    server.on "listening", ->
      console.log "server listening"

    server.on "connection", (socket) ->
      console.log "got connection"

      connections.push socket

      onCmd = createListener socket

      onCmd "create room", (data) ->
        console.log "create room"


module.exports = Server

createListener = (socket, listener) ->
  # give this socket a private object of listeners...
  listeners = {}

  # bind to the low-level data method and pick out
  # the actual payload
  socket.on "data", (data) ->
    data = JSON.parse data
    command = data.command
    delete data.command

    # if this socket has a listener bound for this
    # command then fire it
    listeners[command](data) if listeners[command]

  # the returned function simply allows us to put
  # any amount of listeners on the private object
  return (event, callback) ->
    listeners[event] = callback

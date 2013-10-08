net = require "net"

# currently active rooms
rooms = {}

# possible room keys/names
roomKeys = [
  "a", "b", "c"
]

Server =
  start: (options) ->
    server = net.createServer()
    server.listen 9400

    server.on "listening", ->
      console.log "server listening"

    server.on "connection", (socket) ->
      console.log "got connection"

      superSocket = addConnection socket

      onCmd = createListener socket

      onCmd "create room", ->
        console.log "create room for socket #{superSocket.id}"

        room = createRandomRoom superSocket

        write socket,
          command: "message"
          message: "created new room: #{room.key}"

      onCmd "join room", (data) ->
        console.log "join room #{data.room} for socket #{superSocket.id}"

        joinRoom data.room, superSocket


module.exports = Server

socketId = 0
connections = {}

addConnection = (socket) ->
  socketId += 1

  superSocket =
    # make sure we contain a reference to the underlying connection
    socket: socket
    # the rest of this stuff is our domain layer
    id: socketId
    status: null
    username: null

  connections[socketId] = superSocket

  return superSocket

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

createRandomRoom = (socket) ->
  index = Math.floor(Math.random() * roomKeys.length)
  key = roomKeys[index]
  room =
    users: []
    key: key

  rooms[key] = room

  joinRoom key, socket

  return room

joinRoom = (key, socket) -> rooms[key].users.push socket

write = (socket, data) -> socket.write JSON.stringify data

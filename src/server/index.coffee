net = require "net"
Utils = require "../shared/utils"

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

      onCmd = Utils.createListener socket

      onCmd "create room", ->
        console.log "create room for socket #{superSocket.id}"

        room = createRandomRoom superSocket

        Utils.write socket,
          command: "message"
          message: "created new room: #{room.key}"

      onCmd "join room", (data) ->
        console.log "join room #{data.room} for socket #{superSocket.id}"

        joinRoom data.room, superSocket

        Utils.write socket,
          command: "message"
          message: "joined room: #{data.room}"


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


createRandomRoom = (socket) ->
  index = Math.floor(Math.random() * roomKeys.length)
  key = roomKeys[index]
  room =
    users: []
    key: key

  rooms[key] = room

  # @TODO return the room we've joined || null?
  joinRoom key, socket

  return room

joinRoom = (key, socket) -> rooms[key].users.push socket

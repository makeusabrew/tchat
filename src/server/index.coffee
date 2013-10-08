net = require "net"
SuperSocket = require "../shared/super_socket"

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

    server.on "connection", handleConnection

module.exports = Server

socketId = 0
connections = {}

addConnection = (socket) ->
  socketId += 1

  socket.id = socketId

  connections[socketId] = socket


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

joinRoom = (key, socket) ->
  rooms[key].users.push socket
  socket.room = key

handleConnection = (socket) ->
  console.log "got connection"

  superSocket = new SuperSocket socket
  addConnection superSocket

  superSocket.on "create room", ->
    console.log "create room for socket #{superSocket.id}"

    room = createRandomRoom superSocket

    superSocket.write
      command: "message"
      message: "created new room: #{room.key}"

  superSocket.on "join room", (data) ->
    console.log "join room #{data.room} for socket #{superSocket.id}"

    joinRoom data.room, superSocket

    superSocket.write
      command: "message"
      message: "joined room: #{data.room}"

  superSocket.on "chat", (data) ->
    console.log "chat from #{superSocket.id}: #{data.message}"

    room = rooms[superSocket.room]

    payload =
      command: "message"
      message: data.message

    s.write payload for s in room.users when s.id isnt superSocket.id

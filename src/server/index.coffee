net = require "net"
fs = require "fs"
SuperSocket = require "../shared/super_socket"

# currently active rooms
rooms = {}

# possible room keys/names
roomKeys = []

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
  room = rooms[key]
  room.users.push socket

  socket.room = room

handleConnection = (socket) ->
  console.log "got connection"

  superSocket = new SuperSocket socket
  addConnection superSocket

  superSocket.on "auth", (data) ->
    superSocket.username = data.username
    superSocket.write command: "authed"

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

    superSocket.broadcast
      command: "message"
      message: "#{superSocket.username} joined the room"

  superSocket.on "chat", (data) ->
    console.log "chat from #{superSocket.id}: #{data.message}"

    room = rooms[superSocket.room]

    superSocket.broadcast
      command: "chat"
      user: superSocket.username
      message: data.message

  superSocket.on "status", ->
    console.log "status request from #{superSocket.id}"

stream = fs.createReadStream "/usr/share/dict/words"

stream.on "data", (data) =>
  data = data.toString "utf8"

  for word in data.split("\n")
    if word.search(/'s$/) is -1 and
        word.search(/[éåö]/) is -1 and
        word.length > 2 and
        word.toUpperCase() isnt word

      roomKeys.push word.toLowerCase()

stream.on "end", -> #done

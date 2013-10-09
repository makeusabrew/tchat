net         = require "net"
fs          = require "fs"
SuperSocket = require "../shared/super_socket"

# currently active rooms
rooms = {}

Server =
  start: (options) ->
    populateRoomKeys()
    server = net.createServer()
    server.listen 9400

    server.on "listening", ->
      console.log "server listening"

    server.on "connection", handleConnection

module.exports = Server

socketId = 0

addConnection = (socket) ->
  socketId += 1

  superSocket = new SuperSocket socket

  superSocket.id = socketId

  return superSocket

createRandomRoom = (socket) ->
  index = Math.floor(Math.random() * roomKeys.length)
  key = roomKeys[index]
  room =
    users: []
    key: key

  # @TODO check room not in use
  rooms[key] = room

  # @TODO return the room we've joined || null?
  joinRoom key, socket

  return room

joinRoom = (key, socket) ->
  room = rooms[key]

  # @TODO handle invalid room

  room.users.push socket

  socket.room = room

handleConnection = (socket) ->
  console.log "got connection"

  superSocket = addConnection socket

  identifier = superSocket.id

  #
  # base socket handlers
  #
  socket.on "end", ->
    console.log "socket #{identifier} went away"
    users = superSocket.room.users

    users.splice key, 1 for user, key in users when user.id is superSocket.id

  #
  # augmented socket handlers
  #
  superSocket.on "auth", (data) ->
    console.log "socket #{superSocket.id} authed as #{data.username}"
    superSocket.username = data.username
    identifier += ":#{superSocket.username}"

    superSocket.write "authed"

  superSocket.on "create room", ->
    console.log "create room for socket #{identifier}"

    room = createRandomRoom superSocket

    superSocket.write "message", message: "Created new room: \"#{room.key}\""

  superSocket.on "join room", (data) ->
    console.log "join room #{data.room} for socket #{identifier}"

    joinRoom data.room, superSocket

    superSocket.write "message", message: "Joined room: \"#{data.room}\""

    superSocket.broadcast "message", message: "#{superSocket.username} joined the room"

  superSocket.on "chat", (data) ->
    console.log "chat from #{identifier} -> #{data.message}"

    room = rooms[superSocket.room]

    superSocket.broadcast "chat",
      user: superSocket.username
      message: data.message

  superSocket.on "status", ->
    console.log "status request from #{identifier}"

# possible room keys/names
roomKeys = []
populateRoomKeys = (done = ->) ->
  stream = fs.createReadStream "/usr/share/dict/words"

  stream.on "data", (data) =>
    data = data.toString "utf8"

    for word in data.split("\n")
      if word.search(/'s$/) is -1 and
          word.search(/[éåö]/) is -1 and
          word.length > 2 and
          word.toUpperCase() isnt word

        roomKeys.push word.toLowerCase()

  stream.on "end", done

net         = require "net"
fs          = require "fs"
SuperSocket = require "../shared/super_socket"
config      = require "../shared/config"

# currently active rooms
rooms = {}

Server =
  start: (options) ->
    populateRoomKeys()
    server = net.createServer()
    server.listen config.port

    server.on "listening", ->
      console.log "server listening", server.address()

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

  createRandomRoom socket if rooms[key] and rooms[key].users.length

  room =
    users: []
    key: key

  rooms[key] = room

  joinRoom key, socket

joinRoom = (key, socket) ->
  room = rooms[key]

  return null if not room

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

    return if not superSocket.room

    superSocket.broadcast "leave", user: superSocket.username

    room = superSocket.room

    room.users = (user for user in room.users when user.id isnt superSocket.id)

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

    room = joinRoom data.room, superSocket

    message = if room then "Joined room: \"#{data.room}\"" else "Could not join room \"#{data.room}\" - please try again"
    superSocket.write "message", message: message

    superSocket.broadcast "message", message: "#{superSocket.username} joined the room" if room

  superSocket.on "chat", (data) ->
    console.log "chat from #{identifier} -> #{superSocket.room.key}: #{data.message}"

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
          word.length > 4 and
          word.toUpperCase() isnt word

        roomKeys.push word.toLowerCase()

  stream.on "end", done

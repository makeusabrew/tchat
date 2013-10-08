createListener = (socket) ->
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

class SuperSocket
  constructor: (@socket) ->
    @listener = createListener @socket
    @id = null
    @status = null
    @username = null
    @room = null

  on: (event, callback) -> @listener event, callback

  write: (data) -> @socket.write JSON.stringify data

module.exports = SuperSocket

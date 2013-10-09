createListener = (socket) ->
  # give this socket a private object of listeners...
  listeners = {}

  # bind to the low-level data method and pick out
  # the actual payload
  socket.on "data", (data) ->
    try
      data = JSON.parse data
    catch
      return
    event = data.event
    delete data.event

    # if this socket has a listener bound for this
    # event then fire it
    listeners[event](data) if listeners[event]

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

  write: (event, data = {}) ->
    data.event = event
    @socket.write JSON.stringify data

  broadcast: (event, data) -> s.write event, data for s in @room.users when s.id isnt @id

module.exports = SuperSocket

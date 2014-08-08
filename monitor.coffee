charm = require('charm')()

serialport = require('serialport')
SerialPort = serialport.SerialPort
sp = new SerialPort('/dev/tty.OBDLinkMX-STN-SPP', parser: serialport.parsers.readline('\r'))

messageList = {}
pos = 1

class CanMessage
  @parseArbId: (message) ->
    message[...3]

  constructor: (message) ->
    @arbId = message[...3]
    @data = message[3...]
    @pos = pos++

  update: (message) ->
    @data = message[3...]

  charData: ->
    str = ''
    for byte in @dataPairs()
      int = parseInt(byte, 16)
      if 33 <= int <= 126
        str = "#{str}#{String.fromCharCode(int)}"
      else
        str = "#{str}."

    str

  dataPairs: ->
    @data.match(/.{2}/g)

  render: ->
    charm
      .position(0, @pos)
      .foreground('blue')
      .write(@arbId)
      .right(1)
      .foreground('green')

    for pair in @dataPairs()
      charm
        .write(pair)
        .right(1)

    charm
      .foreground('red')
      .position(40, @pos)
      .write(@charData())

  toString: ->
    "#{@arbId}: #{@data} #{@charData()}"


sp.on 'open', ->
  charm.pipe(process.stdout)
  charm.reset()

  sp.on 'data', (message) ->
    arbId = CanMessage.parseArbId(message)
    lastInstance = messageList[arbId]

    if lastInstance?
      lastInstance.update(message)
      lastInstance.render()
    else
      msg = new CanMessage(message)
      messageList[msg.arbId] = msg
      msg.render()
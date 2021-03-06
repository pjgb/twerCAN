can = require('./can')
charm = require('charm')()
_ = require('underscore')
serialport = require('serialport')
SerialPort = serialport.SerialPort



renderAll = ->
    render(msg, row+1) for msg, row in can.Message.all() when msg.needsRender

render = (msg, row) ->
    charm.position(1, row)

    if msg.needsRender
      msg.needsRender = false

    charm
      .foreground('green')
      .write(msg.arbId)
      .column(5)
      .erase('end')

    for pair, idx in msg.dataBytes()
      if idx in msg.newBytes
        charm.foreground('cyan')
      else
        charm.foreground('blue')

      charm
        .write(pair)
        .right(1)

    charm
      .position(40, row)
      .foreground('red')
      .write(msg.charData())

    setTimeout =>
      charm
        .position(5, row)
        .foreground('blue')
        .right(30)
    , 50



sp = new SerialPort('/dev/tty.OBDLinkMX-STN-SPP', parser: serialport.parsers.readline('\r'))

charm.on '^C', ->
  charm.display('reset')
  sp.close()

sp.on 'close', ->
  process.exit()

sp.on 'open', ->
  # TODO: initialize OBDLink
  # ATS0 - no spaces
  # ATL0 - no linefeeds
  # ATH1 - show headers
  # STP61 - set protocol
  # STMA - monitor all packets

  charm.pipe(process.stdout)
  charm
    .reset()
    .cursor(false)

  sp.on 'data', (message) ->
    arbId = can.factory.parseArbId(message)
    lastInstance = can.Message.find(arbId)

    if lastInstance?
      lastInstance.update(message)
    else
      can.Factory.createMessage(message)

    renderAll()
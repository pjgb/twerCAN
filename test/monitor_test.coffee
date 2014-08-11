can = require('../can')
charm = require('charm')()
charm.pipe(process.stdout)
charm.reset()

ids = [450, 389, 803, 382, 283, 485, 103]

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

setInterval =>
  for id in ids
    msg = id.toString()
    rand1 = Math.floor((Math.random() * 6) + 1)
    for i in [0..rand1]
      byte = Math.floor(Math.random() * 256)
      msg = msg + byte.toString(16)

    arbId = can.Factory.parseArbId(msg)
    lastInstance = can.Message.find(arbId)

    if lastInstance?
      lastInstance.update(msg)
    else
      can.Factory.createMessage(msg)

  renderAll()
, 1000
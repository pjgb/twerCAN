charm = require('charm')()
charm.pipe(process.stdout)
charm.reset()

colors = ['red', 'cyan', 'yellow', 'green', 'blue']
data = [
  '6210108A00000000000'
  '06000005E'
  '13080'
  '2100040000600040008'
  '220410000BC00000048'
  '2302001'
  '09100000000'
  '32001100000000000'
  '4600000AF6EFF'
  '37000800000'
  '6220100400000000000'
  '380000000000000'
]

class CanMessage
  constructor: (message) ->
    @arbId = message[...3]
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

  toString: ->
    "#{@arbId}: #{@data} #{@charData()}"

for d, i in data
  msg = new CanMessage(d)
  charm
    .position(0, i+1)
    .foreground('blue')
    .write(msg.arbId)
    .right(1)
    .foreground('green')

  for pair in msg.dataPairs()
    charm
      .write(pair)
      .right(1)

  charm
    .foreground('red')
    .position(40, i+1)
    .write(msg.charData())
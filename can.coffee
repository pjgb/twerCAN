_ = require('underscore')

class CanMessage
  @messageList: []

  @all: ->
    @messageList

  @find: (arbId) ->
    _.find(@messageList, (msg) -> msg.arbId is arbId)

  constructor: (message) ->
    @arbId = message[...3]
    @data = message[3...]
    @needsRender = true
    @newBytes = []

    insertIndex = _.sortedIndex(CanMessage.messageList, @, (msg) -> parseInt(msg.arbId, 16))
    CanMessage.messageList.splice(insertIndex, 0, @)
    _.each(_.rest(CanMessage.messageList, insertIndex+1), (msg) -> msg.needsRender = true)

  update: (message) ->
    @newBytes = []
    oldBytes = @dataBytes()
    newBytes = message[3...].match(/.{2}/g)
    for idx in [0..oldBytes.length]
      @newBytes.push(idx) unless oldBytes[idx] is newBytes[idx]

    @data = message[3...]
    @needsRender = true

  charData: ->
    str = ''
    for byte in @dataBytes()
      int = parseInt(byte, 16)

      if 33 <= int <= 126
        str = "#{str}#{String.fromCharCode(int)}"
      else
        str = "#{str}."

    str

  dataBytes: ->
    @data.match(/.{2}/g)

  toString: ->
    "#{@arbId}: #{@data} #{@charData()}"

class ClockMessage extends CanMessage
  charData: ->
    str = ''
    bytes = _.map(@dataBytes(), (byte) -> parseInt(byte, 16).toString())
    "#{bytes[1]}/#{bytes[2]}/#{bytes[0]} #{bytes[3]}:#{bytes[4]}:#{bytes[5]}"


class CanFactory
  @parseArbId: (message) ->
    message[...3]

  @createMessage: (message) ->
    switch @parseArbId(message)
      when '520' then new ClockMessage(message)
      else new CanMessage(message)

module.exports =
  Factory: CanFactory
  Message: CanMessage
  ClockMessage: ClockMessage
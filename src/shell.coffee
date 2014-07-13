{Adapter} = require 'hubot'

class KakashiAdapter extends Adapter
  run: -> @emit 'connected'
  close: -> @emit 'closed'
  send: ->
  emote: ->
  reply: ->
  topic: ->
  play: ->

module.exports.use = (robot) ->
  new KakashiAdapter(robot)

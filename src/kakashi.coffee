{Promise} = require 'q'
{Robot, TextMessage} = require 'hubot'
sinon = require 'sinon'

class Kakashi

  constructor: (options={}) ->
    @_httpd = options.httpd ? false
    @_maxCallCount = options.maxCallCount ? 1
    @_name = options.name ? 'hubot'
    @_spy = options.spy ? true
    @_timeout = options.timeout ? 250
    @scripts = options.scripts ? []
    @users = options.users ? []

  start: ->
    new Promise (resolve, reject) =>
      @robot = new Robot(null, 'mock-adapter', @_httpd, @_name)
      @adapter = @robot.adapter # expose
      @_sinon = sinon.sandbox.create()
      @robot.adapter.once 'connected', =>
        if @_spy
          [
            'send'
            'emote'
            'reply'
            'topic'
            'play'
            'http'
          ].forEach (method) =>
            @[method] = @_sinon.stub @robot.adapter, method, =>
              if @[method].callCount >= @_maxCallCount
                @robot.adapter.emit 'finish'
        @robot.catchAll =>
          @robot.adapter.emit 'finish'
        @robot.on 'error', =>
          @robot.adapter.emit 'finish'
        @robot.catchAll =>
          @robot.adapter.emit 'finish'
        @scripts.forEach (script) =>
          script @robot
        @users.forEach (user) =>
          @robot.brain.userForId user.id, user.options
        resolve()
      @robot.run()

  stop: ->
    new Promise (resolve, reject) =>
      @_sinon.restore()
      clearTimeout(@_timeoutId)
      @robot.brain.once 'close', -> resolve()
      @robot.shutdown()
      @robot = null

  receive: (user, text)->
    new Promise (resolve, reject) =>
      @robot.adapter.receive new TextMessage(user, text)
      @robot.adapter.once 'finish', -> resolve()
      @_timeoutId = setTimeout (-> reject(new Error('timeout'))), @_timeout

  # define setters
  [
    'httpd'
    'maxCallCount'
    'name'
    'spy'
    'timeout'
  ].forEach (attr) =>
    @prototype[attr] = (val) ->
      @['_' + attr] = val
      @

module.exports = {Kakashi}

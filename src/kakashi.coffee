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
    @_resolves = {}
    @_rejects = {}
    @scripts = options.scripts ? []
    @users = options.users ? []

  start: ->
    new Promise (resolve, reject) =>
      @_resolves.start = resolve
      @_rejects.start = reject
      @robot = new Robot(__dirname, 'shell', @_httpd, @_name)
      @adapter = @robot.adapter # expose
      @_sinon = sinon.sandbox.create()
      @robot.adapter.on 'connected', =>
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
                @resolve()
        @robot.on 'error', => @reject()
        @robot.catchAll => @reject()
        @users.forEach (user) => @robot.brain.userForId user.id, user.options
        @scripts.forEach (script) => script @robot
        @resolve()
      @robot.run()

  stop: ->
    new Promise (resolve, reject) =>
      @_sinon.restore()
      clearTimeout(@_timeoutId)
      @robot.brain.on 'close', -> resolve()
      @robot.shutdown()

  receive: (user, text)->
    new Promise (resolve, reject) =>
      @_resolves.receive = resolve
      @_rejects.receive = reject
      @robot.adapter.receive new TextMessage(user, text)
      @_timeoutId = setTimeout (=> @reject(new Error('timeout'))), @_timeout

  resolve: (args...) ->
    resolve = null
    ['start', 'receive'].forEach (method) =>
      if @_resolves[method]?
        resolve = @_resolves[method]
        @_resolves[method] = null
        @_rejects[method] = null
    resolve.apply @, args if resolve?

  reject: (args...) ->
    reject = null
    ['start', 'receive'].forEach (method) =>
      if @_rejects[method]?
        reject = @_rejects[method]
        @_resolves[method] = null
        @_rejects[method] = null
    reject.apply @, args if reject?

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

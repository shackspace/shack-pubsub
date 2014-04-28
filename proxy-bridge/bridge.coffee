log4js = require 'log4js'
log = log4js.getLogger 'proxy-bridge'
redis = require 'redis'
WebSocket = require 'ws'
config = require './config'

socket = new WebSocket config.websocket.url
socket.on 'open', ->
	log.info 'open'

sub = redis.createClient config.redis.port, config.redis.host
pub = redis.createClient config.redis.port, config.redis.host

onError = (err) ->
	if err.message.indexOf 'ECONNREFUSED' > 0
		log.warn "can't reach redis", err
	else
		log.err err.message

sub.on 'error', onError
pub.on 'error', onError

socket.on 'message', (data, flags) ->
	# // flags.binary will be set if a binary data is received
	return if flags.binary
	msg = JSON.parse data
	log.info 'ws2redis', msg
	pub.publish msg.channel, msg.message
	# // flags.masked will be set if the data was masked

socket.on 'close', () ->
		log.error 'socket closed'
		process.exit 1 # let forever handle the rest

sub.on 'psubscribe', (channel, count) ->
	log.info 'subscribe', channel, count

sub.on 'pmessage', (pattern, channel, message) ->
	log.info 'redis2ws', channel, message
	socket.send JSON.stringify
		channel: channel
		message: message

sub.psubscribe "*"

# heartbeat
setInterval ->
	log.debug 'send ping'
	alive = false
	socket.once 'pong', ->
		alive = true
		log.debug 'got pong'

	setTimeout ->
		if not alive
			log.fatal 'did not get pong'
			process.exit 1 
	, 5000
	socket.ping()

, 10000
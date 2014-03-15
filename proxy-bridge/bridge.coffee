log4js = require 'log4js'
log = log4js.getLogger 'proxy-bridge'
redis = require 'redis'
WebSocket = require 'ws'

socket = new WebSocket 'ws://localhost:8080'
socket.on 'open', ->
	log.info 'open'

sub = redis.createClient() #config.redis.port, config.redis.host
pub = redis.createClient() #config.redis.port, config.redis.host

onError = (err) ->
	if err.message.indexOf 'ECONNREFUSED' > 0
		log.warn "can't call glados"
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

sub.on 'psubscribe', (channel, count) ->
	log.info 'subscribe', channel, count

sub.on 'pmessage', (pattern, channel, message) ->
	log.info 'redis2ws', channel, message
	socket.send JSON.stringify
		channel: channel
		message: message

sub.psubscribe "*"
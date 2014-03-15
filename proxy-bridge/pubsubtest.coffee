log4js = require 'log4js'
log = log4js.getLogger 'proxy-redis-test'
redis = require 'redis'

sub = redis.createClient() #config.redis.port, config.redis.host
pub = redis.createClient() #config.redis.port, config.redis.host

onError = (err) ->
	if err.message.indexOf 'ECONNREFUSED' > 0
		log.warn "can't call glados"
	else
		log.err err.message

sub.on 'error', onError
pub.on 'error', onError

sub.on 'psubscribe', (channel, count) ->
	log.info 'subscribe', channel, count

sub.on 'pmessage', (pattern, channel, message) ->
	log.info 'redis', channel, message

sub.psubscribe "*"

pub.on 'ready', ->
	pub.publish 'achannel', 'a message!'
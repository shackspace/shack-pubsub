log4js = require 'log4js'
log = log4js.getLogger 'proxy-ws-test'

WebSocket = require 'ws'

socket = new WebSocket 'ws://localhost:8080'
socket.on 'open', ->
	log.info 'open'

socket.on 'message', (msg) ->
	log.info msg

setTimeout ->
	log.info 'send hello'
	socket.send JSON.stringify
		channel: 'hellochannel'
		message: 'hello there?'
, 5000
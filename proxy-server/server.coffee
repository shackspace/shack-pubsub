log4js = require 'log4js'
log = log4js.getLogger 'proxy-server'
uuid = require 'uuid'

WebSocketServer = require('ws').Server
express = require 'express'

config = require './config'

app = express()

# app.use(express.static(__dirname + '/public'));

server = app.listen config.port, ->
	log.info 'listening to port', config.port

wss = new WebSocketServer
	server: server

sockets = {}
wss.on 'connection', (socket) ->
	socket.uuid = uuid.v4()
	sockets[socket.uuid] = socket
	socket.on 'message', (msg) ->
		log.info 'proxy', msg
		for id, otherSocket of sockets
			continue if id is socket.uuid or not otherSocket?
			log.info 'send to', socket.uuid
			otherSocket.send msg

	socket.on 'close', () ->
		log.info 'closing', sockets.uuid
		sockets[socket.uuid] = undefined
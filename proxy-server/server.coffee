log4js = require 'log4js'
log = log4js.getLogger 'proxy-server'
uuid = require 'uuid'

WebSocketServer = require('ws').Server
express = require('express')

app = express()

# app.use(express.static(__dirname + '/public'));

server = app.listen 8080, ->
	log.info 'listening'

wss = new WebSocketServer
	server: server

sockets = {}
wss.on 'connection', (socket) ->
	socket.uuid = uuid.v4()
	sockets[socket.uuid] = socket
	socket.on 'message', (msg) ->
		log.info 'proxy', msg
		for id, otherSocket of sockets
			continue if id is socket.uuid
			log.info 'send to', socket.uuid
			otherSocket.send msg
	# var id = setInterval(function() {
	# 	ws.send(JSON.stringify(process.memoryUsage()), function() { /* ignore errors */ });
	# }, 100);
	# console.log('started client interval');
	# socket.on 'close', function() {
	# 	console.log('stopping client interval');
	# 	clearInterval(id);
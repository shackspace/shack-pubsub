WebSocket = require 'ws'
{EventEmitter} = require 'events'

module.exports = class ShackProxy extends EventEmitter
	constructor: (url) ->
		@socket = new WebSocket url

		@socket.on 'open', =>
			@emit 'open'

		@socket.on 'message', (data) =>
			msg = JSON.parse data
			@emit msg.channel, msg.message

	send: (channel, message) =>
		@socket.send JSON.stringify
			channel: channel
			message: message

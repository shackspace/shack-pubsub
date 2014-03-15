# shack-pubsub

redis pubsub tools for shack infrastructure

## Remote Proxy

Because the shack doesn't really have public ips to provide a service, the internal redis-pubsub has to be proxied to a remote server, where other public services (like the bot) can connect to. This is accomplished by throwing websockets around.

### proxy-server

The proxy server provides a central public access point to the shack pubsub channels.
The master redis server resides inside the shackspace.

### proxy-bridge

To make the shackspace redis pubsub available to the whole interwebs, a bridge sends all messages to the proxy server and injects incoming messages into the redis pubsub.
The bridge connects to the server with a websocket and keeps that websocket open to receive messages.
CONSIDERATIONS: restrict access, auth things, sanity check, acl?

### proxy-client

A client simply receives messages from and sends messages to the proxy server.

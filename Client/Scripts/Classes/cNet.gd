class_name Net
extends Node

static func ssl_connect(tcp_peer:StreamPeerTCP, timeout:int) -> StreamPeerSSL:
	var ssl_peer := StreamPeerSSL.new()
	var err = ssl_peer.connect_to_stream(tcp_peer, false)
	if err: 
		print("ssl connection error:", err)
		ssl_peer = null
		return ssl_peer
	
	var conn_timeout:int = OS.get_ticks_msec() + timeout
	while (ssl_peer.get_status() == StreamPeerSSL.STATUS_HANDSHAKING && 
		OS.get_ticks_msec() < conn_timeout && err == 0):
		pass
	
	if (ssl_peer.get_status() == StreamPeerSSL.STATUS_HANDSHAKING || 
			ssl_peer.get_status() != StreamPeerSSL.STATUS_CONNECTED && err == 0):
		print("SSL Not Completing Handshake")
		ssl_peer = null
	
	return ssl_peer


static func ssl_disconnect(ssl_peer:StreamPeerSSL) -> StreamPeerSSL:
	if ssl_peer != null:
		var status:int = ssl_peer.get_status()
		if status == StreamPeerSSL.STATUS_CONNECTED || \
				status == StreamPeerSSL.STATUS_HANDSHAKING:
			ssl_peer.disconnect_from_stream()
			ssl_peer = null
	return ssl_peer


static func tcp_connect(url:String, port:int, timeout:int) -> StreamPeerTCP:
	var tcp_peer := StreamPeerTCP.new()
	var err:int = tcp_peer.connect_to_host(url, port)
	if err :
		print(url, ":", port, " tcp connection error:", err)
	
	var conn_timeout:int = OS.get_ticks_msec() + timeout
	while (err == OK && 
			tcp_peer.get_status() == StreamPeerTCP.STATUS_CONNECTING && 
			OS.get_ticks_msec() < conn_timeout):
		pass
	
	if (err || tcp_peer.get_status() == StreamPeerTCP.STATUS_CONNECTING || 
			tcp_peer.get_status() != StreamPeerTCP.STATUS_CONNECTED):
		print(url, ":", port, " cannot connect to host")
		err = ERR_CANT_CONNECT
	
	if err:
		tcp_peer = tcp_disconnect(tcp_peer)
	
	return tcp_peer


static func tcp_disconnect(tcp_peer:StreamPeerTCP) -> StreamPeerTCP:
	if tcp_peer != null:
		tcp_peer.disconnect_from_host()
	tcp_peer = null
	return tcp_peer

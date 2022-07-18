extends Node

var url:String = "godot.hopto.org"
#var url:String = "www.stopclock.app"
#var url:String = "stopclock.app"
var port:int = 9999
#var port:int = 42092
var tcp_peer:StreamPeerTCP
var ssl_peer:StreamPeerSSL


func _ready() -> void:
	tcp_peer = StreamPeerTCP.new()
	var err:int = tcp_peer.connect_to_host(url, port)
	if err:
		print_debug("tcp connection error:", err)
	else:
		print("tcp connected")
		
	ssl_peer = StreamPeerSSL.new()
	err = ssl_peer.connect_to_stream(tcp_peer) #will fetch cert from server
#	var cert:X509Certificate = load("res://x509/cert1.crt")
#	err = ssl_peer.connect_to_stream(tcp_peer, true, url, cert) #check the url validity
	if err:
		print_debug("ssl connection error:", err)
	else:
		var status = ssl_peer.get_status()
		if status == StreamPeerSSL.STATUS_CONNECTED:
			print("connected")
		else:
			print("connection failed")
	
	


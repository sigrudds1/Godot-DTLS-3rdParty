extends Node

var ip:String = "192.168.1.230"
var port:int = 8888
var tcp_peer:StreamPeerTCP
var ssl_peer:StreamPeerSSL


func _ready() -> void:
	tcp_peer = StreamPeerTCP.new()
	var err : int = tcp_peer.connect_to_host(ip, port)
	if err :
		print_debug("tcp connection error:", err)
		
	ssl_peer = StreamPeerSSL.new()
	err = ssl_peer.connect_to_stream(tcp_peer) #will fetch cert from server
#	err = ssl_peer.connect_to_stream(tcp_peer, true, "your_server_url") #will fetch cert from server and check the url validity
	if err :
		print_debug("ssl connection error:", err)
	
	var status = ssl_peer.get_status()
	if status == StreamPeerSSL.STATUS_CONNECTED :
		print("connected")
	else:
		print("connection failed")
	


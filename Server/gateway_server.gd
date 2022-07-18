extends Node

const kMaxConns:int = 10

var ssl_key_m:CryptoKey
var ssl_cert_m:X509Certificate
var ssl_chain_m:X509Certificate
var ssl_fullchain_m:X509Certificate
var tcp_server_m:TCP_Server setget _noset
var tcp_peer_threads_m:Array = [] setget _noset
var thr_arr_mutex_m := Mutex.new() setget _noset

var m_tcp_err_m:int setget _noset
var running:bool = true setget _noset

var plyr_tmout:float = 60.0
var time_lapsed:float = 0.0

##################  virtual members ######################################
func _exit_tree() -> void:
	print("quitting")
	running = false
	for thread in tcp_peer_threads_m:
		if thread.is_active():
			thread.wait_to_finish()


func _ready() -> void:
	m_start_tcp()


func _noset(_val) -> void:
	pass


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit()


func _process(_delta) -> void:
	if tcp_server_m.is_connection_available():
		m_thread_array_clean(tcp_peer_threads_m, thr_arr_mutex_m)
		print()
		print("tcp_peer thread count:", tcp_peer_threads_m.size())

		var tcp_peer:StreamPeerTCP = tcp_server_m.take_connection()
		var tcp_host:String = tcp_peer.get_connected_host()
		print("At:", OS.get_unix_time(),  " peer connected:", tcp_host)
		var p_threads:int = tcp_peer_threads_m.size()
		if p_threads < kMaxConns:
			var thr := Thread.new()
			var thr_id := thr.get_instance_id()
			var err = thr.start(self, "m_peer_thread", {
					"tcp_peer": tcp_peer, 
					"inst_id": thr_id
					})
			if err :
				print("thread start err:" + str(err))
			else :
				thr_arr_mutex_m.lock()
				tcp_peer_threads_m.append(thr)
#				print("peer threads:",  tcp_peer_threads_m.size())
				thr_arr_mutex_m.unlock()
		else:
			print("gw dropping peer host:", tcp_host)
			print("peer threads:", p_threads)
			tcp_peer = Net.tcp_disconnect(tcp_peer)


##################  private members ######################################
func m_load_config() -> void:
#	ssl_cert_m = load(Glb.plyr_ssl_cert_path)
#	ssl_key_m = load(Glb.plyr_ssl_key_path)
	
#	ssl_cert_m = load("res://x509Cert/cert1.crt")
	ssl_key_m = load("res://x509Cert/privkey1.key")
	ssl_chain_m = load("res://x509Cert/chain1.crt")
	ssl_fullchain_m = load("res://x509Cert/fullchain1.crt")


func m_peer_send(ssl_peer:StreamPeerSSL, data:Dictionary) -> void:
#	print("m_peer_send:", data)
	if ssl_peer.get_status() == StreamPeerSSL.STATUS_CONNECTED:
		ssl_peer.put_var(data)
	else:
		print("SSL Status Error in m_peer_send()")


func m_peer_thread(data:Dictionary) -> void:
	print("tcp_peer_threads_m:", tcp_peer_threads_m)
	var tcp_peer:StreamPeerTCP = data.tcp_peer
	var tcp_host:String = tcp_peer.get_connected_host()
	var err:int = OK
	var svr_timeout:int = Glb.plyr_conn_timeout
	var ssl_peer := StreamPeerSSL.new()
	
#	err = ssl_peer.accept_stream(tcp_peer, ssl_key_m, ssl_cert_m) 
	err = ssl_peer.accept_stream(tcp_peer, ssl_key_m, ssl_fullchain_m, ssl_chain_m)
	if err:
		print("m_peer_thread - SSL accept stream err code:" + str(err) + 
				" from host:" + tcp_host)
		tcp_peer = Net.tcp_disconnect(tcp_peer)

	var conn_timout:int = OS.get_ticks_msec() + svr_timeout
	while (!err && ssl_peer.get_status() == StreamPeerSSL.STATUS_HANDSHAKING && 
			OS.get_ticks_msec() < conn_timout) :
		ssl_peer.poll()
	while (!err && ssl_peer.get_status() == StreamPeerSSL.STATUS_CONNECTED &&
			OS.get_ticks_msec() < conn_timout) && running:
		if ssl_peer:
			if ssl_peer.get_available_bytes() > 0:
				var peer_data = ssl_peer.get_var()
				print("m_peer_thread - peer_data:", peer_data)
			#polling diconnected causes errors
			if ssl_peer.get_status() == StreamPeerSSL.STATUS_CONNECTED && \
					tcp_peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
						ssl_peer.poll()
	
	ssl_peer = Net.ssl_disconnect(ssl_peer)
	tcp_peer = Net.tcp_disconnect(tcp_peer)
	
	call_deferred("m_thread_array_finished", tcp_peer_threads_m, data.inst_id, 
			thr_arr_mutex_m)


func m_start_tcp() -> void:
	set_process(false)
	running = false
	if tcp_server_m != null:
		if tcp_server_m.is_listening():
			tcp_server_m.stop()
	yield(get_tree().create_timer(1.0), "timeout")
	
	#clear out connection arrays
	while tcp_peer_threads_m.size() > 0:
		m_thread_array_clean(tcp_peer_threads_m, thr_arr_mutex_m)
	
	print(OS.get_datetime())
	print("starting gateway listener")
	print("port:", Glb.plyr_listen_port)
	m_load_config()
	
	tcp_server_m = TCP_Server.new()
	m_tcp_err_m = tcp_server_m.listen(Glb.plyr_listen_port)
	if m_tcp_err_m == null:
		print("Error opening tcp listen port", Glb.plyr_listen_port)
		get_tree().quit()
	running = true
	set_process(true)


func m_thread_array_clean(thr_arr:Array, mutex:Mutex) -> void:
	Utils.thread_array_clean(thr_arr, mutex)


func m_thread_array_finished(thr_arr:Array, inst_id:int, mutex:Mutex) -> void:
	Utils.thread_array_finished(thr_arr, inst_id, mutex)


extends Node

var is_ready:bool = false

var plyr_conn_timeout:int = 2000
var plyr_listen_port:int = 9999
var plyr_max_conns:int = 1000
var plyr_ssl_key_path:String = ""
var plyr_ssl_cert_path:String = ""


func _noset(_val_) -> void:
	pass


func _ready() -> void:
	var exe_dir:String = ProjectSettings.globalize_path("res://")
	if !OS.has_feature("editor"): #if ran by the editor the path is different
		exe_dir = OS.get_executable_path().get_base_dir() + "/"
		
	#IMPORTANT - Make sure the path exist where the server exec is ran standalone
	plyr_ssl_key_path = exe_dir + "x509Cert/test.key"
	plyr_ssl_cert_path = exe_dir + "x509Cert/test.crt"
#	plyr_ssl_key_path = exe_dir + "x509Cert/test_key.key"
#	plyr_ssl_cert_path = exe_dir + "x509Cert/test_crt.crt"
#	plyr_ssl_key_path = exe_dir + "x509Cert/test_key.pem"
#	plyr_ssl_cert_path = exe_dir + "x509Cert/test_crt.pem"
	
#	#Not used for SSL Testing
#	var path:String = exe_dir + "Export/server_cfg.json"
#	var cfg:Dictionary
#	var loading:bool = true
#	while loading:
#		cfg = FileHandler.read_json(path)
#	#	print(path)
#	#	for key in cfg.keys():
#	#		print(key, ":", cfg[key])
#	#	for key in cfg.keys(): #used for copy/pasta
#	#		print(key, " = cfg." , key)
#
#		if cfg.empty() || !cfg.has_all(
#				[
#					"auth_timeout",
#					"auth_server_port",
#					"auth_server_url",
#					"client_version",
#					"client_hash",
#					"cmd_bind_address",
#					"cmd_conn_timeout",
#					"cmd_listen_port",
#					"cmd_max_conns",
#					"backend_conn_timeout",
#					"backend_listen_port",
#					"backend_max_conns",
##					"game_srvr_base_backend_port",
#					"game_srvr_poll_interval",
#					"plyr_conn_timeout",
#					"plyr_listen_port",
#					"plyr_max_conns",
#					"plyr_ssl_cert_path",
#					"plyr_ssl_key_path",
#					"plyr_url",
#					"testing",
#					"testing_accounts"
#				]):
#			print("gateway server config file err")
#			yield(get_tree().create_timer(1.0), "timeout")
#		else:
#			loading = false
#			break
#
#	auth_timeout = cfg.auth_timeout
#	auth_server_port = cfg.auth_server_port
#	auth_server_url = cfg.auth_server_url
#	client_version = cfg.client_version
#	client_hash = cfg.client_hash
#	cmd_bind_address = cfg.cmd_bind_address
#	cmd_conn_timeout = cfg.cmd_conn_timeout
#	cmd_listen_port = cfg.cmd_listen_port
#	cmd_max_conns = cfg.cmd_max_conns
#	backend_conn_timeout = cfg.backend_conn_timeout
#	backend_listen_port = cfg.backend_listen_port
#	backend_max_conns = cfg.backend_max_conns
##	game_srvr_base_backend_port = cfg.game_srvr_base_backend_port
#	game_srvr_poll_interval = cfg.game_srvr_poll_interval
#	plyr_conn_timeout = cfg.plyr_conn_timeout
#	plyr_listen_port = cfg.plyr_listen_port
#	plyr_max_conns = cfg.plyr_max_conns
#	plyr_ssl_cert_path = cfg.plyr_ssl_cert_path
#	plyr_ssl_key_path = cfg.plyr_ssl_key_path
#	plyr_url = cfg.plyr_url
#	testing = cfg.testing
#	testing_accounts = cfg.testing_accounts
#
	is_ready = true

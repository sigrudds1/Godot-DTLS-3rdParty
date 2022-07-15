extends Node

#const kBase64Chars : String = "^[a-zA-Z0-9+/=]*$"
#const kBase64Rfc4648 : String = "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$"
#const kPassword16to128 : String = "^[a-fA-F0-9+/=]{16,128}$" #except 8 to 64bit hex or 128 char base64 hash strings
#const kPasswordHash : String = "^(?=[a-fA-F0-9]*$)(?:.{64}|.{128})$" #except 32bit and 64bit hex hash strings
#const kRegexUsername : String = "^[a-zA-Z0-9_-]{3,64}$" #except alphanumeric _- 3 - 64 chars long
#const kRegexEmai; : String = 	"^[_a-z0-9-]+(.[a-z0-9-]+)@[a-z0-9-]+(.[a-z0-9-]+)*(.[a-z]{2,4})$"

var display_name:RegEx setget _nosetter
var email:RegEx setget _nosetter
var hex:RegEx setget _nosetter
var ipv4:RegEx setget _nosetter
var ipv6:RegEx setget _nosetter
var url:RegEx setget _nosetter
var username:RegEx setget _nosetter
var password_hash:RegEx setget _nosetter
var versioning:RegEx setget _nosetter

func _ready() -> void :
	var err : int = 0
	
	display_name = RegEx.new()
	err |= display_name.compile("^[ a-zA-Z0-9_.#&$-]{3,64}$")
	if err: print("RegEx compile error display_name")
	
	if !err:
		email = RegEx.new()
		err |= email.compile("^[_a-z0-9-]+(.[a-z0-9-]+)@[a-z0-9-]+(.[a-z0-9-]+)*(.[a-z]{2,4})$")
		if err: print("RegEx compile error email")
	
	if !err:
		hex = RegEx.new()
		err |= hex.compile("^[a-fA-F0-9]*$")
		if err: print("RegEx compile error hex")
	
	if !err:
		ipv4 = RegEx.new()
		err |= ipv4.compile("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
		if err: print("RegEx compile error ipv4")
	
	if !err:
		ipv6 = RegEx.new()
		err |= ipv6.compile("(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|" +
				"([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]" + 
				"{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|" + 
				"([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]" +
				"{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}" +
				"(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4})" +
				"{1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4})" +
				"{0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|" + 
				"(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1" +
				"{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|"+ 
				"(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1" +
				"{0,1}[0-9]){0,1}[0-9]))")
		if err: print("RegEx compile error ipv6")
	
	if !err:
		password_hash = RegEx.new()
		err |= password_hash.compile("^[a-zA-Z0-9+/=]*$")
		if err: print("RegEx compile error password_hash")
	
	if !err:
		url = RegEx.new()
		err |= url.compile("[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)")
		if err: print("RegEx compile error url")
	
	if !err:
		username = RegEx.new()
		err |= username.compile("^[a-zA-Z0-9_-]{3,64}$")
		if err: print("RegEx compile error username")
	
	if !err:
		versioning = RegEx.new()
		err |= versioning.compile("^[ 0-9A-Za-z_.-]*$")
		if err: print("RegEx compile error versioning")
	
	if err :
		print("regex err:", err)
		get_tree().quit()

func _nosetter(_val) -> void:
	pass


#public funcs
func check_sanity(data:Dictionary) -> bool:
	var key_count:int = data.size()
	var passed:bool = true
	
	if data.has("client_hash"):
		key_count -= 1
		passed = passed && hex.search(data.client_hash)
		if !passed: print("regex fail client_hash")
	
	if passed && data.has("client_version"):
		key_count -= 1
		passed = passed && versioning.search(data.client_version)
		if !passed: print("regex fail client_version")
	
	if passed && data.has("display_name"):
		key_count -= 1
		passed = passed && display_name.search(data.display_name)
		if !passed: print("regex fail display_name")
		
	if passed && data.has("email"):
		key_count -= 1
		passed = passed && email.search(data.email)
		if !passed: print("regex fail email")
	
	if passed && data.has("FUNC"):
		key_count -= 1
		passed = passed && hex.search(str(data.FUNC))
		if !passed: print("regex fail FUNC")
	
	if passed && data.has("gmsrvr_id"):
		key_count -= 1
		passed = passed && hex.search(str(data.gmsrvr_id))
		if !passed: print("regex fail gmsrvr_id")
	
	if passed && data.has("gw_port"):
		key_count -= 1
		#TODO (Production) add port regex
		data.gw_port = int(data.gw_port)
		passed = passed && data.gw_port > 0 && data.gw_port < 35536
		if !passed: print("regex fail gw_port")
	
	if passed && data.has("gw_url"):
		key_count -= 1
		passed = passed && url.search(data.gw_url)
		if !passed: print("regex fail gw_url")
	
	if passed && data.has("new_pwd_hash"):
		key_count -= 1
		passed = passed && password_hash.search(data.new_pwd_hash)
		if !passed: print("regex fail new_pwd_hash")
	
	if passed && data.has("plyr_id"):
		key_count -= 1
		passed = passed && hex.search(str(data.plyr_id))
		if !passed: print("regex fail plyr_id")
	
	if passed && data.has("pwd_hash"):
		key_count -= 1
		passed = passed && password_hash.search(data.pwd_hash)
		if !passed: print("regex fail pwd_hash")
	
	if passed && data.has("uname"):
		key_count -= 1
		passed = passed && username.search(data.uname)
		if !passed: print("regex fail gw_url")
	
	passed = passed && key_count == 0
	if !passed :
		print("santity failed:", data)
	return passed

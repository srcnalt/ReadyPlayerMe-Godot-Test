extends Node3D

var anim_node: AnimationPlayer
var avatar: Node3D
var http_request: HTTPRequest = HTTPRequest.new()

var draging: bool = false
var difference: float = 0

func _input(event):
	if event is InputEventMouseMotion:
		difference = event.relative.x
	if event is InputEventMouseButton:
		draging = event.is_pressed()

func _process(delta):
	if avatar != null and draging:
		avatar.rotate_y(difference * delta)

func _on_button_pressed():
	if avatar != null:
		avatar.free()
	
	var scene = preload("res://walking.glb").instantiate()
	anim_node = scene.get_node("AnimationPlayer").duplicate()
	
	if $Control/Text.text == "":
		push_error("URL is empty")
	else:
		$Control/Button.disabled = true
		$Control/Button.text = "Loading..."
		
		add_child(http_request)
		http_request.connect("request_completed", _request_completed)
		var error = http_request.request($Control/Text.text)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
			$Control/Button.disabled = false
			$Control/Button.text = "Load Avatar"

func _request_completed(result, response_code, headers, body):
	var gltf = GLTFDocument.new()
	var state = GLTFState.new()
	var error = gltf.append_from_buffer(body, "", state)
	avatar = gltf.generate_scene(state)
		
	anim_node.play("Walk")
	avatar.add_child(anim_node)
	add_child(avatar)
	
	$Control/Button.disabled = false
	$Control/Button.text = "Load Avatar"

extends Node3D;


# camera_move
@export_range(0, 100, 1) var camera_move_speed : float = 20.0;

# camera_rotate
var camera_rotation_direction : int = 0;
@export_range(0, 10, 0.1) var camera_rotation_speed : float = 0.2;
@export_range(0,20,1) var camera_base_rotation_speed : float = 6;


# camera_pan 
@export_range(0, 32, 4) var camera_automatic_pan_margin : int = 10;
@export_range(0, 20, 0.5) var camera_automatic_pan_speed : float = 12;


# camera_ zoom
var camera_zoom_direction : int = 0;
@export_range(0, 100, 1) var camera_zoom_speed = 40.0;
@export_range(0, 100, 1) var camera_zoom_min = 10.0;
@export_range(0, 100, 1) var camera_zoom_max = 25.0;
@export_range(0.2, 0.1) var camera_zoom_speed_damp : float = 0.92;


# Nodes
@onready var camera_socket : Node3D = $CameraSocket;
@onready var camera : Camera3D = $CameraSocket/Camera3D;


# Flags
var camera_can_move_base : bool = false;
var camera_can_process : bool = true;
var camera_can_zoom : bool = true;
var camera_can_rotate : bool = true;
var camera_can_rotate_base : bool = false;
var camera_can_automatic_pan : bool = true;


# Internal Flag
var camera_is_rotating_base : bool = true;


func _ready() -> void:
	pass


func _process(delta : float) -> void:
	camera_base_move(delta);
	camera_zoom_update(delta);
	camera_automatic_pan(delta);
	camera_base_rotate(delta);
	pass


func _unhandled_input(event : InputEvent) -> void:
	# 카메라 줌 제어
	if event.is_action("camera_zoom_in") : camera_zoom_direction = -1;
	if event.is_action("camera_zoom_out") : camera_zoom_direction = 1;

	# 카메라 회전 제어
	if event.is_action_pressed("camera_rotate_right"):
		camera_rotation_direction = -1;
		camera_is_rotating_base = true;
	if event.is_action_pressed("camera_rotate_left"):
		camera_rotation_direction = 1;
		camera_is_rotating_base = true;
	elif event.is_action_released("camera_rotate_left") or event.is_action_released("camera_rotate_right"):
		camera_is_rotating_base = false;


# 카메라의 기반을 화살표 키로 움직입니다.
func camera_base_move(delta : float) -> void:
	if !camera_can_move_base : return;
	var velocity_direction : Vector3 = Vector3.ZERO;

	if Input.is_action_pressed("camera_forward") : velocity_direction -= transform.basis.z;
	if Input.is_action_pressed("camera_backward") : velocity_direction += transform.basis.z;
	if Input.is_action_pressed("camera_right") : velocity_direction += transform.basis.x;
	if Input.is_action_pressed("camera_left") : velocity_direction -= transform.basis.x;
	
	position += velocity_direction.normalized() * camera_move_speed * delta;

# 카메라의 확대/축소를 제어합니다.
func camera_zoom_update(delta : float) -> void:
	if !camera_can_zoom : return;

	var new_zoom : float = clamp(camera.position.z + camera_zoom_speed * camera_zoom_direction * delta, camera_zoom_min, camera_zoom_max);
	camera.position.z = new_zoom;
	camera_zoom_direction *= camera_zoom_speed_damp;


# 카메라의 기반을 회전합니다.
func camera_base_rotate(delta : float) -> void:
	if !camera_can_rotate_base or !camera_is_rotating_base: return;

	
	camera_base_rotate_horizontal(delta, camera_rotation_direction * camera_base_rotation_speed);



func camera_base_rotate_horizontal(delta : float, dir : float) -> void:
	rotation.y += dir * camera_rotation_speed * delta;



func camera_automatic_pan(delta : float) -> void:
	if !camera_can_automatic_pan : return;

	var viewport_current : Viewport = get_viewport();
	var pan_direction : Vector2 = Vector2(-1, -1);
	var viewport_visible_rectangle : Rect2i = Rect2i( viewport_current.get_visible_rect() );
	var viewport_size : Vector2i = viewport_visible_rectangle.size;
	var current_cursor_position : Vector2 = viewport_current.get_mouse_position();
	var margin : float = camera_automatic_pan_margin; #Shortcut
	var zoom_factor : float = camera.position.z * 0.2;

	# Pan X
	if (current_cursor_position.x < margin) or (current_cursor_position.x > viewport_size.x - margin) : 
		if current_cursor_position.x > viewport_size.x / 2 :
			pan_direction.x = 1;
		
		translate(Vector3(pan_direction.x * camera_automatic_pan_speed * zoom_factor * delta, 0, 0));


	# Pan Y
	if (current_cursor_position.y < margin) or (current_cursor_position.y > viewport_size.y - margin) : 
		if current_cursor_position.y > viewport_size.y / 2 :
			pan_direction.y = 1;
		
		translate(Vector3(0, 0, pan_direction.y * camera_automatic_pan_speed * zoom_factor * delta));
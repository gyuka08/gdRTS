extends Node3D;


# camera_move
@export_range(0, 100, 1) var camera_move_speed : float = 20.0;

# camera_rotate
@export_range(0, 10, 0.1) var camera_rotation_speed : float = 0.2;


# camera_pan 
@export_range(0, 32, 4) var camera_automatic_pan_margin : int = 10;
@export_range(0, 20, 0.5) var camera_automatic_pa_speed : float = 12;


# camera_ zoom
var camera_zoom_direction : float = 0;
@export_range(0, 100, 1) var camera_zoom_speed = 40.0;
@export_range(0, 100, 1) var camera_zoom_min = 10.0;
@export_range(0, 100, 1) var camera_zoom_max = 25.0;
@export_range(0.2, 0.1) var camera_zoom_speed_damp : float = 0.92;

# Nodes
@onready var camera_socket : Node3D = $cameraSocket;
@onready var camera : Camera3D = $cameraSocket/Camera3D;


# Flags
var camera_can_move_base : bool = true;
var camera_can_process : bool = true;
var camera_can_zoom : bool = true;
var camera_can_rotate : bool = true;

func _ready() -> void:
    pass


func _process(delta : float) -> void:
    camera_base_move(delta);
    pass


func _unhandled_input(event : InputEvent) -> void:
    pass


func camera_base_move(delta : float) -> void:
    if !camera_can_move_base : return;
    var velocity_direction : Vector3 = Vector3.ZERO;

    if Input.is_action_pressed("camera_forward") : velocity_direction -= transform.basis.z;
    if Input.is_action_pressed("camera_backward") : velocity_direction += transform.basis.x;
    if Input.is_action_pressed("camera_right") : velocity_direction += transform.basis.x;
    if Input.is_action_pressed("camera_left") : velocity_direction -= transform.basis.x;
    
    print(velocity_direction);
    
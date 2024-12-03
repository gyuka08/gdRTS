extends CharacterBody3D

const MODULE_CAMERA : GDScript = preload("res://script/scr_module_camera.gd")

var steer_speed : float = 64.0
var nav_path_goal_position : Vector3

@onready var nav_path_timer : Timer = $Timer

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

func _ready():
	nav_agent.velocity_computed.connect(char_move)
	nav_path_timer.timeout.connect(nav_path_timer_update)

	$Selected.visible = false



func char_move(new_velocity : Vector3) -> void:
	velocity = new_velocity
	move_and_slide()
	rotation.y = atan2(velocity.x, velocity.y)


func selected() -> void:
	$Selected.visible = true



func deselect() -> void:
	$Selected.visible = false


func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_left_click"):
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		var camera : Camera3D = get_viewport().get_camera_3d()
		var camera_raycast_coords : Vector3 = MODULE_CAMERA.get_vector3_from_camera_raycast(camera, mouse_pos)

		if camera_raycast_coords != Vector3.ZERO:
			nav_agent.set_target_position(camera_raycast_coords)
			nav_path_goal_position = camera_raycast_coords


func nav_path_timer_update() -> void:
	if nav_agent.is_navigation_finished(): return

	nav_agent.set_target_position(nav_path_goal_position)


func _physics_process(delta : float) -> void:
	if nav_agent.is_navigation_finished(): return

	var next_position : Vector3 = nav_agent.get_next_path_position()
	var direction : Vector3 = global_position.direction_to(next_position) * nav_agent.max_speed
	var steered_velocity : Vector3 = (direction - velocity) * delta
	var new_agent_velocity : Vector3 = velocity + steered_velocity
	nav_agent.set_velocity(new_agent_velocity)


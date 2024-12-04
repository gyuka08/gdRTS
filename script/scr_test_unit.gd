extends CharacterBody3D

const MODULE_CAMERA : GDScript = preload("res://script/scr_module_camera.gd")

var steer_speed : float = 4.0
var nav_path_goal_position : Vector3

@onready var nav_path_timer : Timer = $Timer
@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var ground_raycast : RayCast3D = $RayCast3D

var rotation_fast : bool = false

var stuck_max : int = 20
var stuck_count : int = 0
var last_position : Vector3



func _ready():

	set_max_slides(2)
	nav_agent.velocity_computed.connect(char_move)
	nav_path_timer.timeout.connect(nav_path_timer_update)

	$Selected.visible = false



func char_move(new_velocity : Vector3) -> void:
	velocity = new_velocity
	var collision : KinematicCollision3D = move_and_collide(new_velocity * get_physics_process_delta_time())
	if collision:
		var collider : Object = collision.get_collider()
		if collider is CharacterBody3D:
			velocity = new_velocity.slide((collision.get_normal()))
		elif collider is StaticBody3D:
			move_and_slide()
	# rotation.y = atan2(velocity.x, velocity.y)


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
			camera_raycast_coords += Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5))
			nav_agent.set_target_position(camera_raycast_coords)
			nav_path_goal_position = camera_raycast_coords


func rotation_to_direction(dir : Vector3, delta : float) -> void:
	if rotation_fast:
		rotation.y = atan2(-dir.x, -dir.z)
	else:
		var pos_2D : Vector2 = Vector2(-transform.basis.z.x, -transform.basis.z.z)
		var goal_2D : Vector2 = Vector2(dir.x, dir.z)
		rotation.y -= pos_2D.angle_to(goal_2D) * steer_speed * delta


func nav_path_timer_update() -> void:
	if nav_agent.is_navigation_finished(): return

	nav_agent.set_target_position(nav_path_goal_position)
	stuck_check()
	last_position = global_position


func stuck_check() -> void:
	if last_position.distance_squared_to(global_position) < 0.8 :
		if stuck_count < stuck_max :
			stuck_count += 1

	
	if stuck_count >= 3:
		if (global_position.distance_squared_to(nav_path_goal_position)) < 10.0 or stuck_count >= stuck_max:
			cancel_navigation()
			stuck_count = 0


func cancel_navigation() -> void:
	nav_agent.emit_signal("navigation_finished")
	nav_agent.set_target_position(global_position)


func _physics_process(delta : float) -> void:
	if nav_agent.is_navigation_finished(): return

	position.y = ground_raycast.get_collision_point().y + 0.4

	var next_position : Vector3 = nav_agent.get_next_path_position()
	var direction : Vector3 = global_position.direction_to(next_position) * nav_agent.max_speed
	var steered_velocity : Vector3 = (direction - velocity) * delta
	var new_agent_velocity : Vector3 = velocity + steered_velocity
	nav_agent.set_velocity(new_agent_velocity)

	rotation_to_direction(direction,  delta)


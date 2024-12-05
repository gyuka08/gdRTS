extends Node2D

const MODULE_CAMERA : GDScript = preload("res://script/scr_module_camera.gd")


@onready var player_camera : Node3D = $CameraBase
@onready var camera_unit_vision_area : Area3D = $CameraBase/UnitVision
@onready var selection_box : NinePatchRect = $SelectionBox

# Variables
@onready var visible_units : Dictionary = {}
@onready var visible_units_array : Array = [] 
# {unit_id : unit_node}
@onready var selection:Array = []

# Constants
const MIN_SELECTION_BOX : int = 128

# Internal Variables
var mouse_left_click : bool = false
var drag_box_area : Rect2


func _ready():
	initialize_interface()


func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_left_click"):
		drag_box_area.position = get_global_mouse_position()
		selection_box.position = drag_box_area.position
		mouse_left_click = true
	if Input.is_action_just_released("mouse_left_click"):
		mouse_left_click = false
		selection_box.visible = false

		var is_shifting : bool = Input.is_action_pressed("shift_shift")

		if drag_box_area.size.length_squared() > MIN_SELECTION_BOX:
			cast_box_selection(is_shifting)
		else:
			cast_selection( get_global_mouse_position(), is_shifting)


	if Input.is_action_just_released("mouse_right_click"):
		if !selection.is_empty():
			var mouse_pos : Vector2 = get_viewport().get_mouse_position()
			var cam : Camera3D = self.get_viewport().get_camera_3d()
			var camera_raycast_coords : Vector3 = MODULE_CAMERA.get_vector3_from_camera_raycast(cam, mouse_pos)

			if camera_raycast_coords != Vector3.ZERO:
				for unit in selection:
					if unit.has_method("move_unit"):
						unit.move_unit(camera_raycast_coords)


func _process(delta : float) -> void:
	if mouse_left_click :
		drag_box_area.size = get_global_mouse_position() - drag_box_area.position
		update_selection_box()

		if !selection_box.visible:
			if drag_box_area.size.length_squared() > MIN_SELECTION_BOX:
				selection_box.visible = true


func unit_entered(u : Node3D) -> void :
	var unit_id : int = u.get_instance_id()
	if visible_units.keys().has(unit_id) : return

	visible_units[unit_id] = u.get_parent()
	# print("unit entered : ", u , " id : ", unit_id, " unit node : ", u.get_parent())
	# debug_units_visible()


func unit_exited(u : Node3D) -> void :
	var unit_id : int = u.get_instance_id()
	if !visible_units.keys().has(unit_id) : return
	
	visible_units.erase(unit_id)
	# print("unit exited : ", u , " id : ", unit_id, " unit node : ", u.get_parent())
	# debug_units_visible()


func debug_units_visible() -> void : 
	print(visible_units)


func initialize_interface() -> void:
	selection_box.visible = false
	camera_unit_vision_area.body_entered.connect(unit_entered)
	camera_unit_vision_area.body_exited.connect(unit_exited)


# func _input(event : InputEvent) -> void:
# 	if Input.is_action_just_pressed("mouse_right_click"):
# 		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
# 		var camera : Camera3D = get_viewport().get_camera_3d()
# 		var camera_raycast_coords : Vector3 = MODULE_CAMERA.get_vector3_from_camera_raycast(camera, mouse_pos)

# 		if camera_raycast_coords != Vector3.ZERO:
# 			camera_raycast_coords += Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5))
# 			nav_agent.set_target_position(camera_raycast_coords)
# 			nav_path_goal_position = camera_raycast_coords


func cast_selection(mouse_pos : Vector2, is_shifting : bool = false) -> void:
	for unit in visible_units_array:
		var unit_pos : Vector2 = player_camera.unproject_position( (unit as Node3D).transform.origin + Vector3(0, 0.85, 0))

		if (mouse_pos.distance_to(unit_pos)) < 30.0:
			if is_shifting:
				selection_add(unit)
				return
			else:
				selection_select_array([unit])
				return

	selection_clear()


func cast_box_selection(is_shifting : bool = false) -> void:
	if !is_shifting: selection_clear()


	for unit in visible_units_array:
		if drag_box_area.abs().has_point( player_camera.unproject_position(unit.transform.origin) ) :
			selection_add(unit)


func selection_add_array(array_of_units : Array) -> void:
	for unit in array_of_units:
		if !selection.has(unit):
			selection_add(unit)


func selection_add(target : Node3D) -> void:
	selection.append(target)
	target.is_selected = true


func selection_remove(target : Node3D) -> void:
	var i : int = 0
	for unit in selection:
		if target == unit:
			selection.remove_at(i)
			target.is_selected = false
			break
		i += 1


func selecttion_remove_array(array_of_units : Array) -> void:
	var i : int = 0
	for unit in selection:
		for target in array_of_units:
			if unit == target:
				selection.remove_at(i)
				unit.is_selected = false
				break
		i += 1


func selection_toggle_select(unit : Node3D) -> void:
	if unit.is_selected:
		selection_remove(unit)
	else:
		selection_add(unit)


func selection_select_array(array_of_units : Array) -> void:
	selection_clear()
	var i : int = 0
	for target in array_of_units:
		if target.is_selected:
			selection.append(target)
			target.is_selected = true
		else:
			target.is_selected = false
			selection.remove_at(i)
		i += 1


func selection_clear() -> void:
	for unit in selection:
		unit.is_selected = false
	selection = []


func update_selection_box() -> void:
	selection_box.size = abs(drag_box_area.size)

	if drag_box_area.size.x > 0:
		selection_box.scale.x = 1
	else:
		selection_box.scale.x = -1

	if drag_box_area.size.y > 0:
		selection_box.scale.y = 1
	else:
		selection_box.scale.y = -1
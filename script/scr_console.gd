extends Node2D

@onready var player_camera : Node3D = $CameraBase
@onready var camera_unit_vision_area : Area3D = $CameraBase/UnitVision
@onready var selection_box : NinePatchRect = $SelectionBox

# Variables
@onready var visible_units : Dictionary = {}
# {unit_id : unit_node}

# Constants
const SELECTION_BOX_MIN : int = 164

# Internal Variables
var mouse_left_click : bool = false
var drag_box_area : Rect2


func _ready():
	initialize_interface()


func unit_entered(u : Node3D) -> void :
	var unit_id : int = u.get_instance_id()
	if visible_units.keys().has(unit_id) : return

	visible_units[unit_id] = u.get_parent()
	print("unit entered : ", u , " id : ", unit_id, " unit node : ", u.get_parent())
	# debug_units_visible()


func unit_exited(u : Node3D) -> void :
	var unit_id : int = u.get_instance_id()
	if !visible_units.keys().has(unit_id) : return
	
	visible_units.erase(unit_id)
	print("unit exited : ", u , " id : ", unit_id, " unit node : ", u.get_parent())
	# debug_units_visible()


func debug_units_visible() -> void : 
	print(visible_units)


func initialize_interface() -> void:
	selection_box.visible = false
	camera_unit_vision_area.body_entered.connect(unit_entered)
	camera_unit_vision_area.body_exited.connect(unit_exited)


func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_left_click"):
		drag_box_area.position = get_global_mouse_position()
		selection_box.position = drag_box_area.position
		mouse_left_click = true
	if Input.is_action_just_released("mouse_left_click"):
		mouse_left_click = false
		selection_box.visible = false
		cast_selection()


func cast_selection() -> void:
	for unit in visible_units.values():
		if unit is CharacterBody3D:
			if drag_box_area.abs().has_point( player_camera.get_vector2_from_vector3(unit.transform.origin) ) :
				unit.selected()
			else:
				unit.deselect()


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

func _process(delta : float) -> void:
	if mouse_left_click :
		drag_box_area.size = get_global_mouse_position() - drag_box_area.position
		update_selection_box()

		if !selection_box.visible:
			if drag_box_area.size.length_squared() > SELECTION_BOX_MIN:
				selection_box.visible = true

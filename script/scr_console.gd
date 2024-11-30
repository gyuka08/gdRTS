extends Node2D

@onready var player_camera : Node3D = $CameraBase
@onready var camera_unit_vision_area : Area3D = $CameraBase/UnitVision
@onready var selection_box : NinePatchRect = $SelectionBox

# Variables
@onready var visible_units : Dictionary = {}
# {unit_id : unit_node}

func _ready():
	initialize_interface()


func unit_entered(u : Node3D) -> void :
	var unit_id : int = u.get_instance_id()
	if visible_units.keys().has(unit_id) : return

	visible_units[unit_id] = u.get_parent()
	print("unit entered : ", u , " id : ", unit_id, " unit node : ", u.get_parent())
	debug_units_visible()


func unit_exited(u : Node3D) -> void :
	var unit_id : int = u.get_instance_id()
	if !visible_units.keys().has(unit_id) : return
	
	visible_units.erase(unit_id)
	print("unit exited : ", u , " id : ", unit_id, " unit node : ", u.get_parent())
	debug_units_visible()


func debug_units_visible() -> void : 
	print(visible_units)


func initialize_interface() -> void:
	selection_box.visible = false
	camera_unit_vision_area.body_entered.connect(unit_entered)
	camera_unit_vision_area.body_exited.connect(unit_exited)


func _process(delta : float):
	pass

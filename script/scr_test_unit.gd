extends Node3D

func _ready():
	$Selected.visible = false


func selected() -> void:
	$Selected.visible = true

func deselect() -> void:
	$Selected.visible = false
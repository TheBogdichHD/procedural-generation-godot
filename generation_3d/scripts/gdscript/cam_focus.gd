extends Node3D


@export var rot_speed = 10.0


func _process(delta):
	rotation_degrees.y += rot_speed * delta

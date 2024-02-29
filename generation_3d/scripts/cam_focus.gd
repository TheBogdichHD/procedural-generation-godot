extends Node3D


var rot_speed = 10.0


func _process(delta):
	rotation_degrees.y += rot_speed * delta

extends Node3D


var rot_speed = 10.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	rotation_degrees.y += rot_speed * delta

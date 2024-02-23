extends Node3D

var mesh : ArrayMesh: set = _set_mesh
var prototype : Dictionary
var debug_text

var text


func _set_mesh(new_mesh):
	$MeshInstance3D.mesh = new_mesh
	

func _on_col_area_mouse_entered():
	if debug_text:
		debug_text.text = str(prototype)


func _on_col_area_mouse_exited():
	if debug_text.text:
		debug_text.text = ""

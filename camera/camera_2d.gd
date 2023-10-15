extends Camera2D

@export var move_speed: float = 4
@export var zoom_speed: float = 0.1
@export var zoom_lower_bound: float = 0
@export var zoom_upper_bound: float = 2

func _process(_delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	position += direction * move_speed


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("right_click"):
			position -= event.relative / zoom.x

	if event.is_action_pressed("scroll_up"):
		var new_zoom = zoom * (1 + zoom_speed)
		
		if new_zoom.x < zoom_upper_bound:
			var previous_mouse_position = get_local_mouse_position()
			zoom = new_zoom
			var diff = previous_mouse_position - get_local_mouse_position()
			offset += diff
	
	elif event.is_action_pressed("scroll_down"):
		var new_zoom = zoom * (1 - zoom_speed)
		
		if new_zoom.x > zoom_lower_bound:
			var previous_mouse_position = get_local_mouse_position()
			zoom = new_zoom
			var diff = previous_mouse_position - get_local_mouse_position()
			offset += diff

#func zoom_camera(direction: int) -> void:
#	var new_zoom = get_zoom() + Vector2(scroll_speed, scroll_speed) * direction
#
#	if new_zoom.x > zoom_lower_bound:
#		var previous_mouse_position = get_local_mouse_position()
#		zoom = new_zoom
#		var diff = previous_mouse_position - get_local_mouse_position()
#		offset += diff

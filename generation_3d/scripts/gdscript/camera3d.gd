extends Camera3D


const LOOK_SENS = 0.005
const ROLL_SPEED = 1.0
const SCROLL_WHEEL_UP_INDEX = 4
const SCROLL_WHEEL_DOWN_INDEX = 5

var mouse_modes = [
	Input.MOUSE_MODE_CAPTURED,
	Input.MOUSE_MODE_CONFINED
]


@export var move_speed = 1.0
var mouse_mode = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	var movement_vector = Vector3.ZERO
	var roll = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		movement_vector += Vector3.FORWARD
	if Input.is_action_pressed("move_backward"):
		movement_vector += Vector3.BACK
	if Input.is_action_pressed("move_right"):
		movement_vector += Vector3.RIGHT
	if Input.is_action_pressed("move_left"):
		movement_vector += Vector3.LEFT
	if Input.is_action_pressed("move_up"):
		movement_vector += Vector3.UP
	if Input.is_action_pressed("move_down"):
		movement_vector += Vector3.DOWN
	if Input.is_action_just_pressed("cycle_mouse"):
		mouse_mode += 1
		mouse_mode = (mouse_mode % 2)
		print(mouse_mode)
		Input.set_mouse_mode(mouse_modes[mouse_mode])
	
	translate_object_local(movement_vector.normalized() * delta * move_speed)
	
	if Input.is_action_pressed("roll_r"):
		roll += Vector3.FORWARD
	if Input.is_action_pressed("roll_l"):
		roll += Vector3.BACK
	
	if roll:
		rotate_object_local(roll, ROLL_SPEED * delta)

func _input(event):
	if mouse_mode == 1:
		Input.set_mouse_mode(mouse_modes[mouse_mode])
		return
	var mouse_delta = Vector2.ZERO
	if event is InputEventMouseMotion:
		mouse_delta = event.relative * LOOK_SENS
		rotate_y(-mouse_delta.x)
		rotate_object_local(Vector3.RIGHT, -mouse_delta.y)
	elif event is InputEventMouseButton:
		if event.button_index == SCROLL_WHEEL_UP_INDEX:
			move_speed *= 1.5
		elif event.button_index == SCROLL_WHEEL_DOWN_INDEX:
			move_speed *= 0.75

extends TileMap

@export var size: Vector2i = Vector2i(50, 35)
@export var start_cell: Vector2i = Vector2i(-15, -10)

var tile_map: TileMap = self
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var wave_function: Array
var stack: Array
var prototype_data: Dictionary
var all_weights: Array[Array]
var start_entropy = 5

func _ready() -> void:
	var arr: Array
	for x in range(0, size.x):
		arr.append(start_entropy)
	
	for y in range(0, size.y):
		all_weights.append(arr.duplicate())
		
	wave_function_collapse()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		wave_function_collapse()


func wave_function_collapse():
	load_prototype_data()
	initialize(size, prototype_data)
	collapse()
	fill_grid()
	wave_function.clear()


func fill_grid() -> void:
	for y in range(0, size.y):
		for x in range(0, size.x):
			var data = wave_function[y][x]
			if data:
				var atlas_coords = prototype_data[data[0]]["atlas_coords"]
				tile_map.set_cell(0, Vector2i(x, y) + start_cell, 0, Vector2i(atlas_coords[0], atlas_coords[1]))

#func generate_random() -> void:
#	for i in range(start_cell.x, start_cell.x + size.x):
#		for j in range(start_cell.y, start_cell.y + size.y):
#			set_cell(0, Vector2i(i,j), 0, Vector2i(rng.randi_range(0,3), 0))

func load_prototype_data() -> void:
	var file_data = FileAccess.open("res://prototype_data.json", FileAccess.READ)
	var prototypes = JSON.parse_string(file_data.get_as_text())
	
	prototype_data = prototypes


func initialize(new_size: Vector2i, all_prototypes: Dictionary) -> void:
	size = new_size
	for _y in range(size.y):
		var x = []
		for _x in range(size.x):
			x.append(all_prototypes.keys().duplicate())
		wave_function.append(x)


func collapse() -> void:
	while not is_collapsed():
		iterate()

func is_collapsed() -> bool:
	for y in wave_function:
		for x in y:
			if x.size() > 1:
				return false
	return true


func iterate():
	var coords = get_min_entropy_coords()
	collapse_at(coords)
	propagate(coords)


func get_min_entropy_coords() -> Vector2i:
	var min_entropy = 100
	
	var j = -1
	var i = -1
	for y in wave_function:
		j += 1
		for x in y:
			i += 1
			if x.size() > 1:
				var weights = []
				for t in x:
					weights.append(prototype_data[t]["weight"])
				var calc = 0
				var sum = 0
				for t in weights:
					sum += t
					min_entropy -= t * log(t)
				calc /= sum
				calc += log(sum)
				min_entropy = min(min_entropy, calc)
				all_weights[j][i] = min_entropy
		i = -1
	
	
	var min_cords: Array
	
	for y in range(0, size.y):
		for x in range(0, size.x):
			if all_weights[y][x] == min_entropy:
				min_cords.append(Vector2i(x, y))
	
	return min_cords.pick_random()


func collapse_at(coords) -> void:
	var possibilities: Array
	for p in wave_function[coords.y][coords.x]:
		possibilities.append(p)
	
	var collapsed = possibilities.pick_random()
	
	var lenght = len(wave_function[coords.y][coords.x])
	
	for i in range(lenght-1, -1, -1):
		if wave_function[coords.y][coords.x][i] != collapsed:
			wave_function[coords.y][coords.x].remove_at(i)


func propagate(co_ords) -> void:
	stack.append(co_ords)
	
	while len(stack) > 0:
		var cur_coords = stack.pop_back()
		
		for d in valid_dirs(cur_coords):
			var other_coords = (cur_coords + d)
			var other_possible_prototypes = get_possibilities(other_coords).duplicate()
			
			var possible_neighbours = get_possible_neighbours(cur_coords)
			
			if len(other_possible_prototypes) == 0:
				continue
			
			for other_prototype in other_possible_prototypes:
				if not other_prototype in possible_neighbours:
					constrain(other_coords, other_prototype)
					if not other_coords in stack:
						stack.append(other_coords)


func valid_dirs(cur_coords) -> Array:
	var dirs: Array
	
	if cur_coords.x != 0:
		dirs.append(Vector2i(-1, 0))
	if cur_coords.x != size.x-1:
		dirs.append(Vector2i(1, 0))
	if cur_coords.y != 0:
		dirs.append(Vector2i(0, -1))
	if cur_coords.y != size.y-1:
		dirs.append(Vector2i(0, 1))
	return dirs


func get_possibilities(other_coords):
	return wave_function[other_coords.y][other_coords.x]


func get_possible_neighbours(cur_coords):
	var data = wave_function[cur_coords.y][cur_coords.x]
	var possibilities = []
	
	for i in range(0, len(data)):
		for p in prototype_data[data[i]]["valid_neighbours"]:
			if not p in possibilities:
				possibilities.append(p)
	return possibilities

func constrain(other_coords, other_prototype) -> void:
	wave_function[other_coords.y][other_coords.x].erase(other_prototype)

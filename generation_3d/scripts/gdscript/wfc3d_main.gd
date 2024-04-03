extends Node


@export var size = Vector3(8, 3, 8)

@export var my_seed = 0
@export var update = false

@onready var grid_map = $GridMap
@onready var seed_label = $Labels/SeedLabel

var wfc : WFC3D_Model
var meshes : Array
var coords : Vector3



func _ready():
	seed_label.text = "Seed: " + str(my_seed)
	test()


func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		change_seed()
		test()


func test():
	clear_meshes()
	seed(hash(str(my_seed)))
	var prototypes = load_prototype_data()
	wfc = WFC3D_Model.new()
	add_child(wfc)
	wfc.initialize(size, prototypes)
	
	apply_custom_constraints()
	
	if update:
		while not wfc.is_collapsed():
			wfc.iterate()
			clear_meshes()
			visualize_wave_function()
			await get_tree().process_frame
		
		if len(grid_map.get_meshes()) == 0:
			change_seed()
			test()
		else:
			clear_meshes()
		
	else:
		regen_no_update()
		
	visualize_wave_function()


func regen_no_update():
	while not wfc.is_collapsed():
		wfc.iterate()
	
	visualize_wave_function()
	if len(grid_map.get_meshes()) == 0:
		change_seed()
		test()


func apply_custom_constraints():
	for z in range(size.z):
		for y in range(size.y):
			for x in range(size.x):
				coords = Vector3(x, y, z)
				var protos = wfc.get_possibilities(coords)
				if y == size.y - 1:  # constrain top layer to not contain any uncapped prototypes
					for proto in protos.duplicate():
						var neighs = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.pZ]
						if not "p-1" in neighs:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if y > 0:  # everything other than the bottom
					for proto in protos.duplicate():
						var custom_constraint = protos[proto][WFC3D_Model.CONSTRAIN_TO]
						if custom_constraint == WFC3D_Model.CONSTRAINT_BOTTOM:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if y < size.y - 1:  # everything other than the top
					for proto in protos.duplicate():
						var custom_constraint = protos[proto][WFC3D_Model.CONSTRAIN_TO]
						if custom_constraint == WFC3D_Model.CONSTRAINT_TOP:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if y == 0:  # constrain bottom layer so we don't start with any top-cliff parts at the bottom
					for proto in protos.duplicate():
						var neighs  = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.nZ]
						var custom_constraint = protos[proto][WFC3D_Model.CONSTRAIN_FROM]
						if (not "p-1" in neighs) or (custom_constraint == WFC3D_Model.CONSTRAINT_BOTTOM):
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if x == size.x - 1: # constrain +x
					for proto in protos.duplicate():
						var neighs  = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.pX]
						if not "p-1" in neighs:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if x == 0: # constrain -x
					for proto in protos.duplicate():
						var neighs  = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.nX]
						if not "p-1" in neighs:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if z == size.z - 1: # constrain +z
					for proto in protos.duplicate():
						var neighs  = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.nY]
						if not "p-1" in neighs:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				if z == 0: # constrain -z
					for proto in protos.duplicate():
						var neighs  = protos[proto][WFC3D_Model.NEIGHBOURS][WFC3D_Model.pY]
						if not "p-1" in neighs:
							protos.erase(proto)
							if not coords in wfc.stack:
								wfc.stack.append(coords)
				
	
	wfc.propagate(false, false)


func load_prototype_data():
	var json_as_text = FileAccess.get_file_as_string("res://generation_3d/meshes/meshes_faster_gen/prototype_data.json")
	var json_as_dict = JSON.parse_string(json_as_text)
	return json_as_dict


func visualize_wave_function(only_collapsed=true):
	for z in range(size.z):
		for y in range(size.y):
			for x in range(size.x):
				var prototypes = wfc.wave_function[z][y][x]
				
				if only_collapsed:
					if len(prototypes) > 1:
						continue
				
				for prototype in prototypes:
					var dict = wfc.wave_function[z][y][x][prototype]
					var mesh_name = dict[wfc.MESH_NAME]
					var mesh_rot = dict[wfc.MESH_ROT]
					
					if mesh_name == "-1":
						continue
					
					var rot_index
					
					match int(mesh_rot):
						0: rot_index = 0
						1: rot_index = 16
						2: rot_index = 10
						3: rot_index = 22
					
					grid_map.set_cell_item(Vector3i(x,y,z), int(mesh_name), rot_index)

func change_seed():
	my_seed += 1
	seed_label.text = "Seed: " + str(my_seed)

func clear_meshes():
	grid_map.clear()

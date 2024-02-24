extends Node


const size = Vector3(8, 3, 8)
const unit_size = 1.0
const mesh_string = "res://generation_3d/meshes/%s.res"

@export var my_seed = 6
@export var update = false
@onready var module = preload("res://generation_3d/scenes/module.tscn")

var wfc : WFC3D_Model
var meshes : Array
var coords : Vector3



func _ready():
	test()


func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		my_seed += 1
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
		
		if len(meshes) == 0:
			my_seed += 1
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
	if len(meshes) == 0:
		my_seed += 1
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
	var json_as_text = FileAccess.get_file_as_string("res://generation_3d/prototype_data.json")
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
					
					var inst = module.instantiate()
					meshes.append(inst)
					add_child(inst)
					inst.mesh = load(mesh_string % mesh_name)
					inst.rotate_y((PI/2) * mesh_rot)
					inst.position = Vector3(x*unit_size, y*unit_size, z*unit_size)
					inst.prototype = {prototype: dict}
					inst.debug_text = $DebugText


func clear_meshes():
	for mesh in meshes:
		mesh.queue_free()
	meshes = []

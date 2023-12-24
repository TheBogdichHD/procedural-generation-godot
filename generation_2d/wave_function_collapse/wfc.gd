extends TileMap

signal left_click

@export var world_x = 0
@export var world_y = 0
@export var world_w = 50
@export var world_h = 30
@export var wait_time = 0.00
@export var interactive = true
@export var tile_info_name = ""

var entropy_text = preload("res://z_archive/entropy_text.tscn")
var tile_info
var tile_map = self
var world
var entropy_texts = []
#var random = RandomNumberGenerator.new()

func _ready():
	tile_info = load(tile_info_name).new()
	init_entropy_text()
	world = World.new(world_w, world_h, tile_info)
	fill_tile_map()
#	random.randomize()
#	random_gen()


#func random_gen():
#	var cell_number =  len(tile_info.tile_sprites.keys())-1
#	for y in world_h:
#		for x in world_w:
#			var random_tile = tile_info.tile_sprites[random.randi_range(0, cell_number)]
#			tile_map.set_cell(0, Vector2i(x, y), 0, random_tile)


func _unhandled_input(event):
	if event.is_action_pressed("reset"):
		show_all_texts()
		world = World.new(world_w, world_h, tile_info)
		tile_map.clear()
		fill_tile_map()
	elif event.is_action_pressed("left_click"):
		left_click.emit()


func fill_tile_map():
	if not interactive:
		while world.wave_function_collapse():
			pass
		draw_world()
	else:
		while world.wave_function_collapse():
			draw_world()
			await left_click


func init_entropy_text():
	var entropy = str(len(tile_info.tile_rules.keys()))
	for y in world_h:
		var texts = []
		for x in world_w:
			var entropy_text_instance = entropy_text.instantiate()
			add_child(entropy_text_instance)
			entropy_text_instance.position = Vector2((x+world_x)*16, (y+world_y)*16)
			entropy_text_instance.text = entropy
			texts.append(entropy_text_instance)
		entropy_texts.append(texts)


func show_all_texts():
	for y in world_h:
		for x in world_w:
			entropy_texts[y][x].show()

func draw_world():
	var lowest_entropy = world.get_lowest_entropy()
	for y in world_h:
		for x in world_w:
			var tile_type = world.get_type(x, y)
#			if tile_type != -1:
#				var atlas_coords = tile_info.tile_sprites[tile_type]
#				if tile_type < tile_info.NEEDS_GRASS:
#					tile_map.set_cell(0, Vector2i(x+world_x, y+world_y), 0, atlas_coords)
#				else:
#					tile_map.set_cell(1, Vector2i(x+world_x, y+world_y), 0, atlas_coords)
#					tile_map.set_cell(0, Vector2i(x+world_x, y+world_y), 0, Vector2i(1,0))
			if tile_type != -1:
				if entropy_texts[y][x].visible:
					entropy_texts[y][x].hide()
				var atlas_coords = tile_info["tile_sprites"][tile_type]
				if tile_type < tile_info.NEEDS_GRASS:
					tile_map.set_cell(0, Vector2i(x+world_x, y+world_y), 0, atlas_coords)
				else:
					tile_map.set_cell(1, Vector2i(x+world_x, y+world_y), 0, atlas_coords)
					tile_map.set_cell(0, Vector2i(x+world_x, y+world_y), 0, Vector2i(1,0))
			else:
				var entropy = world.get_entropy(x, y)
				entropy_texts[y][x].text = str(entropy)
				if entropy > 10:
					entropy_texts[y][x].set_modulate(Color.GRAY)
					entropy_texts[y][x].add_theme_font_size_override("font_size", 9)
				else:
					if entropy == lowest_entropy:
						entropy_texts[y][x].set_modulate(Color.GREEN)
						entropy_texts[y][x].add_theme_font_size_override("font_size", 13)
					else:
						entropy_texts[y][x].set_modulate(Color.WHITE)
						entropy_texts[y][x].add_theme_font_size_override("font_size", 12)

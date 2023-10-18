extends TileMap

@export var world_x = 30
@export var world_y = 20
@export var start_x = -world_x/2
@export var start_y = -world_y/2
@export var wait_time = 0.08
@export var interactive = true

var tile_info = preload("res://generation_2d/wave_function_collapse/tile_info.tres")
var entropy_text = preload("res://generation_2d/wave_function_collapse/entropy_text.tscn")
var tile_map = self
var world
var entropy_texts = []

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	world = World.new(world_x, world_y)
	init_entropy_text()
	fill_tile_map()


func _unhandled_input(event):
	if event.is_action_pressed("reset"):
		tile_map.clear()
		show_all_texts()
		world = World.new(world_x, world_y)
		fill_tile_map()

func fill_tile_map():
	if not interactive:
		while world.wave_function_collapse():
			pass
		draw_world()
	else:
		while world.wave_function_collapse():
			draw_world()
			await get_tree().create_timer(wait_time).timeout 


func init_entropy_text():
	var entropy = str(len(tile_info.tile_rules.keys()))
	for y in world_y:
		var texts = []
		for x in world_x:
			var entropy_text_instance = entropy_text.instantiate()
			add_child(entropy_text_instance)
			entropy_text_instance.position = Vector2((x+start_x)*16, (y+start_y)*16)
			entropy_text_instance.text = entropy
			texts.append(entropy_text_instance)
		entropy_texts.append(texts)


func show_all_texts():
	for y in world_y:
		for x in world_x:
			entropy_texts[y][x].show()

func draw_world():
	var lowest_entropy = world.get_lowest_entropy()
	
	for y in world_y:
		for x in world_x:
			var tile_type = world.get_type(x, y)
			if tile_type != -1:
				if entropy_texts[y][x].visible:
					entropy_texts[y][x].hide()
				var atlas_coords = tile_info["tile_sprites"][tile_type]
				if tile_type < tile_info.TILE_FORESTN:
					tile_map.set_cell(0, Vector2i(x+start_x, y+start_y), 1, atlas_coords)
				else:
					tile_map.set_cell(1, Vector2i(x+start_x, y+start_y), 1, atlas_coords)
					tile_map.set_cell(0, Vector2i(x+start_x, y+start_y), 1, Vector2i(0,0))
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

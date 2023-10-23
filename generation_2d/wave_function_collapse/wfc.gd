extends TileMap

@export var world_x = 0
@export var world_y = 0
@export var world_w = 50
@export var world_h = 30
@export var wait_time = 0.00
@export var interactive = true
@export var tile_info_name = ""

var tile_info
var tile_map = self
var world
var entropy_texts = []


func _ready():
	tile_info = load(tile_info_name).new()
	world = World.new(world_w, world_h, tile_info)
	fill_tile_map()


func _unhandled_input(event):
	if event.is_action_pressed("reset"):
		world = World.new(world_w, world_h, tile_info)
		tile_map.clear()
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


func draw_world():
	for y in world_h:
		for x in world_w:
			var tile_type = world.get_type(x, y)
			if tile_type != -1:
				var atlas_coords = tile_info.tile_sprites[tile_type]
				if tile_type < tile_info.NEEDS_GRASS:
					tile_map.set_cell(0, Vector2i(x+world_x, y+world_y), 0, atlas_coords)
				else:
					tile_map.set_cell(1, Vector2i(x+world_x, y+world_y), 0, atlas_coords)
					tile_map.set_cell(0, Vector2i(x+world_x, y+world_y), 0, Vector2i(1,0))

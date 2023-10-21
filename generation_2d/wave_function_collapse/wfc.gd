extends TileMap

@export var world_x = 70
@export var world_y = 50
@export var start_x = -world_x/2
@export var start_y = -world_y/2
@export var wait_time = 0.00
@export var interactive = true

var tile_info = preload("res://generation_2d/wave_function_collapse/tile_info_nature.gd").new()
var tile_map = self
var world
var entropy_texts = []


func _ready():
	#RenderingServer.set_default_clear_color(Color.DARK_SLATE_BLUE)
	world = World.new(world_x, world_y)
	fill_tile_map()


func _unhandled_input(event):
	if event.is_action_pressed("reset"):
		world = World.new(world_x, world_y)
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
	for y in world_y:
		for x in world_x:
			var tile_type = world.get_type(x, y)
			if tile_type != -1:
				var atlas_coords = tile_info.tile_sprites[tile_type]
				if tile_type < tile_info.TILE_ROCKN:
					tile_map.set_cell(0, Vector2i(x+start_x, y+start_y), 0, atlas_coords)
				else:
					tile_map.set_cell(1, Vector2i(x+start_x, y+start_y), 0, atlas_coords)
					tile_map.set_cell(0, Vector2i(x+start_x, y+start_y), 0, Vector2i(1,0))

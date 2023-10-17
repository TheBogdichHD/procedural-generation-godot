extends TileMap

@export var world_x = 80
@export var world_y = 60
@export var start_x = -world_x/2
@export var start_y = -world_y/2
@export var wait_time = 0.00

var tile_info = preload("res://generation_2d/wave_function_collapse/tile_info.tres")
var tile_map = self
var world


func _ready():
	world = World.new(world_x, world_y)
	fill_tile_map()

func fill_tile_map():
	while world.wave_function_collapse():
		var tiles = world.tile_rows
		
		for y in world_y:
			for x in world_x:
				var tile_type = world.get_type(x, y)
				if tile_type != -1:
					var atlas_coords = tile_info["tile_sprites"][tile_type]
					if tile_type < tile_info.TILE_FORESTN:
						tile_map.set_cell(0, Vector2i(x+start_x, y+start_y), 1, atlas_coords)
					else:
						tile_map.set_cell(1, Vector2i(x+start_x, y+start_y), 1, atlas_coords)
						tile_map.set_cell(0, Vector2i(x+start_x, y+start_y), 1, Vector2i(0,0))
		
		await get_tree().create_timer(wait_time).timeout 

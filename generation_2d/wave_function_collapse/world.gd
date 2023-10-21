class_name World
extends Node

var tile_info = preload("res://generation_2d/wave_function_collapse/tile_info_nature.gd").new()
var cols
var rows
var tile_rows = []


func _init(size_x, size_y):
	cols = size_x
	rows = size_y
	
	for y in size_y:
		var tiles = []
		for x in size_x:
			var tile = Tile.new(tile_info)
			tiles.append(tile)
		tile_rows.append(tiles)
	
	for y in size_y:
		for x in size_x:
			var tile = tile_rows[y][x]
			if y > 0:
				tile.add_neighbour(tile_info.NORTH, tile_rows[y - 1][x])
			if x < size_x - 1:
				tile.add_neighbour(tile_info.EAST, tile_rows[y][x + 1])
			if y < size_y - 1:
				tile.add_neighbour(tile_info.SOUTH, tile_rows[y + 1][x])
			if x > 0:
				tile.add_neighbour(tile_info.WEST, tile_rows[y][x - 1])


func get_entropy(x, y):
	return tile_rows[y][x].entropy


func get_type(x, y):
	return tile_rows[y][x].tile_type


func get_lowest_entropy():
	var lowest_entropy = len(tile_info.tile_rules.keys())
	for y in range(rows):
		for x in range(cols):
			var tile_entropy = tile_rows[y][x].entropy
			if tile_entropy > 0:
				if tile_entropy < lowest_entropy:
					lowest_entropy = tile_entropy
	
	return lowest_entropy


func get_tiles_lowest_entropy():
	var lowest_entropy = len(tile_info.tile_rules.keys())
	var tile_list = []
	
	for y in rows:
		for x in cols:
			var tile_entropy = tile_rows[y][x].entropy
			if tile_entropy > 0:
				if tile_entropy < lowest_entropy:
					tile_list.clear()
					lowest_entropy = tile_entropy
				if tile_entropy == lowest_entropy:
					tile_list.append(tile_rows[y][x])
	return tile_list


func wave_function_collapse():
	var tiles_lowest_entropy = get_tiles_lowest_entropy()
	
	if tiles_lowest_entropy == []:
		return false
	
	var tile_to_collapse = tiles_lowest_entropy.pick_random()
	tile_to_collapse.collapse()
	
	var stack = []
	stack.push_back(tile_to_collapse)
	
	while stack.size() != 0:
		var tile = stack.pop_back()
		var tile_possibilities = tile.get_possibilities()
		var directions = tile.get_directions()
	
		for direction in directions:
			var neighbour = tile.get_neighbour(direction)
			if neighbour.entropy != 0:
				var reduced = neighbour.constrain(tile_possibilities, direction)
				if reduced == true:
					stack.push_back(neighbour)
	
	return true

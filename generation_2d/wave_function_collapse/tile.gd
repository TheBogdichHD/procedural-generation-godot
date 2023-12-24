class_name Tile
extends Node

var tile_info
var possibilities
var entropy
var neighbours

var random = RandomNumberGenerator.new()
var tile_type = -1


func _init(tile_info_c):
	tile_info = tile_info_c
	possibilities = tile_info.tile_rules.keys()
	entropy = len(possibilities)
	neighbours = {}
	random.randomize()


func add_neighbour(direction, tile):     
	neighbours[direction] = tile


func get_neighbour(direction):
	return neighbours[direction]


func get_directions():
	return neighbours.keys()


func get_possibilities():
	return possibilities


func get_weighted_entropy():
	var weighted_entropy = 0
	
	for possibility in possibilities:
		var weight = tile_info.tile_weights[possibility]
		weighted_entropy += weight * log(weight)
	
	return weighted_entropy


func collapse():
	var weights = []
	for possibility in possibilities:
		weights.append(tile_info.tile_weights[possibility])
	
	tile_type = possibilities[weighted_random(weights)]
	possibilities.clear()
	possibilities.append(tile_type)
	entropy = 0


func weighted_random(weights):
	var weights_sum = 0.0
	for weight in weights:
		weights_sum += weight
	
	var remaining_distance = random.randf() * weights_sum
	for i in weights.size():
		remaining_distance -= weights[i]
		if remaining_distance < 0:
			return i
	
	return 0


func constrain(neighbourPossibilities, direction):
	var reduced = false
	
	if entropy > 0:
		var connectors = []
		for neighbourPossibility in neighbourPossibilities:
			connectors.append(tile_info.tile_rules[neighbourPossibility][direction])
		
		var opposite
		# check opposite side
		if direction == tile_info.NORTH: opposite = tile_info.SOUTH
		if direction == tile_info.EAST:  opposite = tile_info.WEST
		if direction == tile_info.SOUTH: opposite = tile_info.NORTH
		if direction == tile_info.WEST:  opposite = tile_info.EAST
		
		var mapped_connectors = connectors.map(func(str): return str[0])
		
		var len = len(possibilities)
		for i in range(len - 1, -1, -1):
			var tile_pos = tile_info.tile_rules[possibilities[i]][opposite]
			if tile_pos.contains('x'):
				if tile_pos in connectors:
					possibilities.remove_at(i)
					reduced = true
			elif tile_pos not in mapped_connectors:
				possibilities.remove_at(i)
				reduced = true
		
		entropy = len(possibilities)
		
	return reduced

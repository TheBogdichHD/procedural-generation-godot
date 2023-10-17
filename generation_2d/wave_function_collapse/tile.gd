class_name Tile
extends Node

var tile_info = preload("res://generation_2d/wave_function_collapse/tile_info.tres")
var possibilities
var entropy
var neighbours

var total_weight = 0.0
var random = RandomNumberGenerator.new()
var tile_type = -1


func _init():
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
		
		for possibility in possibilities.duplicate():
			if tile_info.tile_rules[possibility][opposite] not in connectors:
				possibilities.erase(possibility)
				reduced = true
		
		entropy = len(possibilities)
		
	return reduced

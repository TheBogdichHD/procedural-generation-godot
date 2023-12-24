# Directions
var NORTH = 0
var EAST  = 1
var SOUTH = 2
var WEST  = 3

var NEEDS_GRASS   = 31

# Tile Types
var TILE_GRASS   = 0
var TILE_PATH    = 1
var TILE_PATHN   = 3
var TILE_PATHE   = 4
var TILE_PATHS   = 5
var TILE_PATHW   = 6
var TILE_PATHNE  = 7
var TILE_PATHSE  = 8
var TILE_PATHSW  = 9
var TILE_PATHNW  = 10
var TILE_PATHNE2 = 11
var TILE_PATHSE2 = 12
var TILE_PATHSW2 = 13
var TILE_PATHNW2 = 14
var TILE_PATHVN = 15
var TILE_PATHVS = 16
var TILE_PATHVM = 17
var TILE_PATHM = 18
var TILE_PATHHE = 19
var TILE_PATHHM = 20
var TILE_PATHHW = 21
var TILE_PATHSSW = 22
var TILE_PATHSSEW = 23
var TILE_PATHSSE = 24
var TILE_PATHSSNW = 25
var TILE_PATHSM = 26
var TILE_PATHSSNE = 27
var TILE_PATHSNW = 28
var TILE_PATHSNEW = 29
var TILE_PATHSNE = 30

# Tile Edges
var GRASS   = 0
var PATH    = 1
var PATH_N  = 2
var PATH_E  = 3
var PATH_S  = 4
var PATH_W  = 5

# Dictionary of all tile types and tile edges, on the directions [North, East, South, West]
var tile_rules = {
	TILE_GRASS   : [GRASS, GRASS, GRASS, GRASS],
	TILE_PATH   : [PATH, PATH, PATH, PATH],
	TILE_PATHN  : [GRASS, PATH_N, PATH, PATH_N],
	TILE_PATHE  : [PATH_E, GRASS, PATH_E, PATH],
	TILE_PATHS  : [PATH, PATH_S, GRASS, PATH_S],
	TILE_PATHW  : [PATH_W, PATH, PATH_W, GRASS],
	TILE_PATHNE : [GRASS, GRASS, PATH_E, PATH_N],
	TILE_PATHSE : [PATH_E, GRASS, GRASS, PATH_S],
	TILE_PATHSW : [PATH_W, PATH_S, GRASS, GRASS],
	TILE_PATHNW : [GRASS, PATH_N, PATH_W, GRASS],
	TILE_PATHNE2: [PATH_E, PATH_N, PATH, PATH],
	TILE_PATHSE2: [PATH, PATH_S, PATH_E, PATH],
	TILE_PATHSW2: [PATH, PATH, PATH_W, PATH_S],
	TILE_PATHNW2: [PATH_W, PATH, PATH, PATH_N],
#	TILE_PATHVN: [GRASS, GRASS, PATH, GRASS],
#	TILE_PATHVM: [PATH, GRASS, PATH, GRASS],
#	TILE_PATHVS: [PATH, GRASS, GRASS, GRASS],
#	TILE_PATHM: [GRASS, GRASS, GRASS, GRASS],
#	TILE_PATHHE: [GRASS, GRASS, GRASS, PATH],
#	TILE_PATHHM: [GRASS, PATH, GRASS, PATH],
#	TILE_PATHHW: [GRASS, PATH, GRASS, GRASS],
#	TILE_PATHSSW: [GRASS, GRASS, PATH_E, PATH_N],
#	TILE_PATHSSEW: [GRASS, PATH_N, PATH, PATH_N],
#	TILE_PATHSSE: [GRASS, PATH_N, PATH_W, GRASS],
#	TILE_PATHSSNW: [PATH_E, GRASS, PATH_E, PATH],
#	TILE_PATHSM: [PATH, PATH, PATH, PATH],
#	TILE_PATHSSNE: [PATH_W, PATH, PATH_W, GRASS],
#	TILE_PATHSNW: [PATH_E, GRASS, GRASS, PATH_S],
#	TILE_PATHSNEW: [PATH, PATH_S, GRASS, PATH_S],
#	TILE_PATHSNE: [PATH_W, PATH_S, GRASS, GRASS],
}


var tile_weights = {
	TILE_GRASS    : 16,
	TILE_PATH    : 4,
	TILE_PATHN   : 5,
	TILE_PATHE   : 5,
	TILE_PATHS   : 5,
	TILE_PATHW   : 5,
	TILE_PATHNE  : 5,
	TILE_PATHSE  : 5,
	TILE_PATHSW  : 5,
	TILE_PATHNW  : 5,
	TILE_PATHNE2 : 2,
	TILE_PATHSE2 : 2,
	TILE_PATHSW2 : 2,
	TILE_PATHNW2 : 2,
	TILE_PATHVN: 2,
	TILE_PATHVS: 2,
	TILE_PATHVM: 2,
	TILE_PATHM: 2,
	TILE_PATHHE: 2,
	TILE_PATHHM: 2,
	TILE_PATHHW: 2,
	TILE_PATHSSW:2 ,
	TILE_PATHSSEW:2,
	TILE_PATHSSE:2,
	TILE_PATHSSNW:2,
	TILE_PATHSM:2,
	TILE_PATHSSNE:2,
	TILE_PATHSNW:2,
	TILE_PATHSNEW:2,
	TILE_PATHSNE:2,
}


var tile_sprites = {
	TILE_GRASS : Vector2i(0, 0),
	TILE_PATH : Vector2i(11, 1),
	TILE_PATHN  : Vector2i(11, 0),
	TILE_PATHE  : Vector2i(12, 1),
	TILE_PATHS  : Vector2i(11, 2),
	TILE_PATHW  : Vector2i(10, 1),
	TILE_PATHNE : Vector2i(12, 0),
	TILE_PATHSE : Vector2i(12, 2),
	TILE_PATHSW : Vector2i(10, 2),
	TILE_PATHNW : Vector2i(10, 0),
	TILE_PATHNE2: Vector2i(14, 0),
	TILE_PATHSE2: Vector2i(14, 1),
	TILE_PATHSW2: Vector2i(13, 1),
	TILE_PATHNW2: Vector2i(13, 0),
	TILE_PATHVN:Vector2i(3, 0),
	TILE_PATHVS:Vector2i(3, 2),
	TILE_PATHVM:Vector2i(3, 1),
	TILE_PATHM:Vector2i(3, 3),
	TILE_PATHHE:Vector2i(4, 3),
	TILE_PATHHM:Vector2i(5, 3),
	TILE_PATHHW:Vector2i(6, 3),
	TILE_PATHSSW:Vector2i(4, 0),
	TILE_PATHSSEW:Vector2i(5, 0),
	TILE_PATHSSE:Vector2i(6, 0),
	TILE_PATHSSNW:Vector2i(4, 1),
	TILE_PATHSM:Vector2i(5, 1),
	TILE_PATHSSNE:Vector2i(6, 1),
	TILE_PATHSNW:Vector2i(4, 2),
	TILE_PATHSNEW:Vector2i(5, 2),
	TILE_PATHSNE:Vector2i(6, 2),
}
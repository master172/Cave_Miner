tool
extends Node2D

var map_x : int = 0
var map_y : int = 0

var chunk_size :int = 16

var world_seed :String = "Hello, World!"
var noise_octaves :int = 3
var noise_period :int = 3
var noise_persistence :float = 0.7
var noise_lacunarity :float = 0.4

var noise_threshold :float = 0.5

var redraw :bool = false
var clear_with_redraw :bool = true

var unload_chunk_x :int = 0
var unload_chunk_y :int = 0
var unload_chunk_size :int = 16

var unload :bool = false

var tileMap : TileMap
var SimplexNoise : OpenSimplexNoise = OpenSimplexNoise.new()

var chunks_to_generate :int = 4

var last_chunk_x :int = 0
var last_chunk_y :int = 0

var first_chunk_x :int = 0
var first_chunk_y :int = 0

var _generation_thread = Thread.new()
func _ready():
	self.tileMap = get_parent() as TileMap
	if Engine.editor_hint:
		if self.tileMap == null:
			return
		else:
			clear()
			generate()
	else:
		if self.tileMap == null:
			return
		else:
			Utils.Map_TileMap = self.tileMap
			clear()
			for x in range(-chunks_to_generate,chunks_to_generate+1):
				for y in range(-chunks_to_generate,chunks_to_generate+1):
					map_x = x *chunk_size
					map_y = y *chunk_size
					clear_with_redraw = false
					generate()
					last_chunk_x = map_x
					last_chunk_y = map_y
			first_chunk_x = -chunks_to_generate*chunk_size
			first_chunk_y = -chunks_to_generate*chunk_size

			for x in range(-1,1):
				for y in range(-1,1):
					_unset_autotile(x,y)
					self.tileMap.update_bitmask_area(Vector2(x,y))
					self.tileMap.update_dirty_quadrants()

func clear():
	self.tileMap.clear()

func generate():
	self.SimplexNoise.seed = self.world_seed.hash()
	self.SimplexNoise.octaves = self.noise_octaves
	self.SimplexNoise.period = self.noise_period
	self.SimplexNoise.persistence = self.noise_persistence
	self.SimplexNoise.lacunarity = self.noise_lacunarity

	for x in range(map_x - chunk_size, map_x + chunk_size):
		for y in range(map_y - chunk_size, map_y + chunk_size):

			if not Engine.editor_hint:
				if ChunkSaver.WorldChanges.has(Vector2(x,y)):
					tileMap.set_cellv(Vector2(x,y),ChunkSaver.WorldChanges[Vector2(x,y)])
					continue
				else:
					if self.SimplexNoise.get_noise_2d(x+self.get_global_position().x,y+self.get_global_position().y) < self.noise_threshold:
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
						self._set_autotile(x+self.get_global_position().x,y+self.get_global_position().y)
			else:
				if self.SimplexNoise.get_noise_2d(x+self.get_global_position().x,y+self.get_global_position().y) < self.noise_threshold:
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
										self._set_autotile(x+self.get_global_position().x,y+self.get_global_position().y)
	self.tileMap.update_dirty_quadrants()
	self.tileMap.update_bitmask_region(Vector2(map_x - chunk_size, map_y -chunk_size), Vector2(map_x + chunk_size, map_y + chunk_size))

func _unload_chunks():
	
	for x in range(unload_chunk_x - unload_chunk_size ,unload_chunk_x+ unload_chunk_size):
		for y in range(unload_chunk_y - unload_chunk_size ,unload_chunk_y+unload_chunk_size):
			_unset_autotile(x,y)

	self.tileMap.update_dirty_quadrants()
	self.tileMap.update_bitmask_region(Vector2(unload_chunk_x - unload_chunk_size,unload_chunk_y-unload_chunk_size),Vector2(unload_chunk_x + unload_chunk_size,unload_chunk_y+unload_chunk_size))
			
			

func _set_autotile(x : int, y: int):
	self.tileMap.set_cell(
		x,
		y,
		self.tileMap.get_tileset().get_tiles_ids()[0],
		false,
		false,
		false,
		self.tileMap.get_cell_autotile_coord(x,y)
	)
	self.tileMap.update_bitmask_area(Vector2(x,y))

func _unset_autotile(x : int,y:int):
	self.tileMap.set_cell(
		x,
		y,
		-1,
		false,
		false,
		false,
		self.tileMap.get_cell_autotile_coord(x,y)
	)
	self.tileMap.update_bitmask_area(Vector2(x,y))

func _get(property):
	
	#the map dimensions variables
	if property == 'map_properties/map_dimensions/map_dimensions/map_x':
		return map_x
		
	elif property == 'map_properties/map_dimensions/map_dimensions/map_y':
		return map_y
	
	elif property == 'map_properties/map_dimensions/map_dimensions/chunk_size':
		return chunk_size
	
	#the map open simplex noise properties
	
	elif property == 'map_properties/map_noise_properties/world_seed':
		return world_seed
	
	elif property == 'map_properties/map_noise_properties/noise_octaves':
		return noise_octaves
	
	elif property == 'map_properties/map_noise_properties/noise_period':
		return noise_period
	
	elif property == 'map_properties/map_noise_properties/noise_persistence':
		return noise_persistence
	
	elif property == 'map_properties/map_noise_properties/noise_lacunarity':
		return noise_lacunarity
		
	# the map generation variables
	elif property == 'map_properties/map_generation_properties/noise_threshold':
		return noise_threshold
	
	elif property == 'map_properties/map_generation_properties/redraw':
		return redraw
	
	elif property == 'map_properties/map_generation_properties/clear_with_redraw':
		return clear_with_redraw
	
	#the map unloading properties
	
	elif property == 'map_properties/chunk_unloading_properties/unload_chunk_x':
		return unload_chunk_x
	
	elif property == 'map_properties/chunk_unloading_properties/unload_chunk_y':
		return unload_chunk_y
	
	elif property == 'map_properties/chunk_unloading_properties/unload_chunk_size':
		return unload_chunk_size
	
	elif property == 'map_properties/chunk_unloading_properties/unload':
		return unload
			
func _set(property : String, value):
	
	#the map dimensions variables
	if property == 'map_properties/map_dimensions/map_dimensions/map_x':
		map_x= value
		
	elif property == 'map_properties/map_dimensions/map_dimensions/map_y':
		map_y = value

	elif property == 'map_properties/map_dimensions/map_dimensions/chunk_size':
		chunk_size = value
	
	#the map open simplex properties
	elif property == 'map_properties/map_noise_properties/world_seed':
		world_seed = value
	
	elif property == 'map_properties/map_noise_properties/noise_octaves':
		noise_octaves = value
	
	elif property == 'map_properties/map_noise_properties/noise_period':
		noise_period = value
	
	elif property == 'map_properties/map_noise_properties/noise_persistence':
		noise_persistence = value
	
	elif property == 'map_properties/map_noise_properties/noise_lacunarity':
		noise_lacunarity = value
		
	# the map generation properties
	
	elif property == 'map_properties/map_generation_properties/noise_threshold':
		noise_threshold = value
	
	elif property == 'map_properties/map_generation_properties/redraw':
		redraw = value
		if value == true:
			if clear_with_redraw == true:
				if self.tileMap != null:
					clear()
					generate()
					redraw = false
			else:
				if self.tileMap != null:
					generate()
					redraw = false

	elif property == 'map_properties/map_generation_properties/clear_with_redraw':
		clear_with_redraw = value
	
	#the map unloading properties

	elif property == 'map_properties/chunk_unloading_properties/unload_chunk_x':
		unload_chunk_x = value
	
	elif property == 'map_properties/chunk_unloading_properties/unload_chunk_y':
		unload_chunk_y = value
	
	elif property == 'map_properties/chunk_unloading_properties/unload_chunk_size':
		unload_chunk_size = value
	
	elif property == 'map_properties/chunk_unloading_properties/unload':
		unload = value
		if value == true:
			_unload_chunks()
			unload = false

	return true

func _get_property_list():
	var props = []

	#the map dimensions x variables
	props.append(
		{
			'name':'map_properties/map_dimensions/map_dimensions/map_x',
			'type':TYPE_INT
		}
	)
	props.append(
		{
			'name':'map_properties/map_dimensions/map_dimensions/map_y',
			'type':TYPE_INT
		}
	)
	#the map dimensions y variables
	
	props.append(
		{
			'name':'map_properties/map_dimensions/map_dimensions/chunk_size',
			'type':TYPE_INT
		}
	)
	
	#the open simplex noise properties
	props.append(
		{
			'name':'map_properties/map_noise_properties/world_seed',
			'type':TYPE_STRING
		}
	)
	
	props.append(
		{
			'name':'map_properties/map_noise_properties/noise_octaves',
			'type':TYPE_INT
		}
	)
	props.append(
		{
			'name':'map_properties/map_noise_properties/noise_period',
			'type':TYPE_INT
		}
	)
	props.append(
		{
			'name':'map_properties/map_noise_properties/noise_persistence',
			'type':TYPE_REAL
		}
	)
	props.append(
		{
			'name':'map_properties/map_noise_properties/noise_lacunarity',
			'type':TYPE_REAL
		}
	)
	
	#the map generation properties
	props.append(
		{
			'name':'map_properties/map_generation_properties/noise_threshold',
			'type':TYPE_REAL
		}
	)
	props.append(
		{
			'name':'map_properties/map_generation_properties/redraw',
			'type':TYPE_BOOL
		}
	)
	props.append(
		{
			'name':'map_properties/map_generation_properties/clear_with_redraw',
			'type':TYPE_BOOL
		}
	)
	# the chunk unloading map_properties

	props.append(
		{
			'name':'map_properties/chunk_unloading_properties/unload_chunk_x',
			'type':TYPE_INT
		}
	)
	props.append(
		{
			'name':'map_properties/chunk_unloading_properties/unload_chunk_y',
			'type':TYPE_INT
		}
	)
	props.append(
		{
			'name':'map_properties/chunk_unloading_properties/unload_chunk_size',
			'type':TYPE_INT
		}
	)

	props.append(
		{
			'name':'map_properties/chunk_unloading_properties/unload',
			'type':TYPE_BOOL
		}
	)
	
	return props


func _free_chunks_up():
	for x in range(first_chunk_x,last_chunk_x+1):
		if x % (unload_chunk_size*2) == 0:
			
			unload_chunk_x = x
			unload_chunk_y = last_chunk_y
			_unload_chunks()
	
	last_chunk_y -= (unload_chunk_size*2)

	map_y = first_chunk_y - (chunk_size*2)
	
	for x in range(first_chunk_x,last_chunk_x+1):
		if x % (unload_chunk_size*2) == 0:
			map_x = x
			map_y = map_y
			generate()
	
	first_chunk_y -= (chunk_size * 2)



func _free_chunks_down():
	for x in range(first_chunk_x,last_chunk_x+1):
		if x % (unload_chunk_size*2) == 0:
			
			unload_chunk_x = x
			unload_chunk_y = first_chunk_y
			_unload_chunks()
	
	first_chunk_y += (unload_chunk_size*2)

	map_y = last_chunk_y + (chunk_size*2)

	for x in range(first_chunk_x,last_chunk_x+1):
		if x % (unload_chunk_size*2) == 0:
			map_x = x
			map_y = map_y
			generate()
	
	last_chunk_y += (chunk_size * 2)


	

func _free_chunks_left():
	for y in range(first_chunk_y,last_chunk_y+1):
		if y % (unload_chunk_size*2) == 0:

			unload_chunk_x = first_chunk_x
			unload_chunk_y = y
			_unload_chunks()
	
	first_chunk_x += (unload_chunk_size*2)

	map_x = last_chunk_x + (chunk_size*2)

	for y in range(first_chunk_y,last_chunk_y+1):
		if y % (chunk_size*2) == 0:
			map_x = map_x
			map_y = y
			generate()
	
	last_chunk_x += (chunk_size*2)



func _free_chunks_right():
	for y in range(first_chunk_y,last_chunk_y+1):
		if y % (unload_chunk_size*2) == 0:

			unload_chunk_x = last_chunk_x
			unload_chunk_y = y
			_unload_chunks()
	
	last_chunk_x -= (unload_chunk_size*2)

	map_x = first_chunk_x - (chunk_size*2)

	for y in range(first_chunk_y,last_chunk_y+1):
		if y % (chunk_size*2) == 0:
			map_x = map_x
			map_y = y
			generate()
	
	first_chunk_x -= (chunk_size*2)
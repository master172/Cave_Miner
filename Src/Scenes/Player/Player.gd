extends KinematicBody2D

export (int) var speed = 200

var velocity = Vector2()

var old_position : Vector2 = Vector2(0,0)
var new_position : Vector2 = Vector2(0,0)


func _ready():
	old_position = Vector2(self.get_global_position().x, self.get_global_position().y)
	Utils.Player = self


func _check_new_position():
	
	new_position = (self.get_global_position()).floor()

	if old_position != new_position:
		
		if old_position.x - new_position.x >512:
			Utils.Map_TileMap.get_child(0)._free_chunks_right()
			old_position.x = new_position.x
		
		if new_position.x - old_position.x > 512:
			if Utils.Map_TileMap != null:
				Utils.Map_TileMap.get_child(0)._free_chunks_left()
			old_position.x = new_position.x
		
		if old_position.y - new_position.y > 512:
			if Utils.Map_TileMap != null:
				Utils.Map_TileMap.get_child(0)._free_chunks_up()
			old_position.y = new_position.y

		if new_position.y - old_position.y > 512:
			if Utils.Map_TileMap != null:
				Utils.Map_TileMap.get_child(0)._free_chunks_down()
			old_position.y = new_position.y

		

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	get_input()
	_check_new_position()
	velocity = move_and_slide(velocity)

func _input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("place"):
			if Utils.Map_TileMap != null:
				var place_position: Vector2 = get_global_mouse_position()
				place_position = place_position / Utils.Map_TileMap.cell_size
				place_position = place_position.floor()

				ChunkSaver.WorldChanges[place_position] = 0
				Utils.Map_TileMap.set_cellv(place_position,0)
				Utils.Map_TileMap.update_bitmask_area(place_position)
				return

		elif Input.is_action_just_pressed("break") or Input.is_action_pressed("break"):
			if Utils.Map_TileMap != null:
				var place_position: Vector2 = get_global_mouse_position()
				place_position = place_position / Utils.Map_TileMap.cell_size
				place_position = place_position.floor()

				if Utils.Map_TileMap.get_cell(place_position.x,place_position.y) == TileMap.INVALID_CELL:
					return

				ChunkSaver.WorldChanges[place_position] = -1

				Utils.Map_TileMap.set_cellv(place_position,-1)
				Utils.Map_TileMap.update_bitmask_area(place_position)	

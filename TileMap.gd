extends TileMap

var active : ActiveTetro = null
var move_ticks : int = 0

func _ready():
#	for tile_id in self.tile_set.get_tiles_ids():
#		print(tile_id, self.tile_set.tile_get_name(tile_id)) # red, green etc.
#	for used_cell in self.get_used_cells():
#		print(used_cell)
#		print(self.get_cell(used_cell.x, used_cell.y))
	pass

func spawn_tetro():
	var tetromino_type = Tetromino.random_type()
	self.active = ActiveTetro.new(
		self,
		Tetromino.TILE.GREEN,
		tetromino_type,
		Tetromino.starting_pivot_for_type(tetromino_type),
		Tetromino.DIRECTION.UP
	)

func _process(delta):
	if self.active == null:
		if self.move_ticks > 0:
			self.spawn_tetro()
			self.move_ticks = 0
		return

	var collision : bool = self.active.move_vertical(move_ticks)
	if collision:
		self.active = null
	
	self.move_ticks = 0

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
			return
	if event.is_action_pressed("ui_rotate_clockwise"):
		if self.active != null:
			self.active.rotate(Tetromino.ROTATION.CLOCKWISE)
		else:
			print("active is null - CLOCKWISE")
	if event.is_action_pressed("ui_rotate_counterclockwise"):
		if self.active != null:
			self.active.rotate(Tetromino.ROTATION.COUNTERCLOCKWISE)
		else:
			print("active is null - COUNTER")
			pass
	if event.is_action_pressed("ui_left"):
		if self.active != null:
			self.active.move_horizontal(-1)
	if event.is_action_pressed("ui_right"):
		if self.active != null:
			self.active.move_horizontal(1)

class ActiveTetro:
	var tile_map : TileMap
	var tile_id : int
	
	var pivot : Vector2
	var type : int
	var direction : int
	
	func _init(tile_map : TileMap, tile_id : int, type : int, pivot : Vector2, direction : int):
		self.tile_map = tile_map
		self.tile_id = tile_id
		self.type = type
		self.pivot = pivot
		self.direction = direction
		self.draw()
	
	func rotate(rotation : int) -> void:
		var next_direction : int = Tetromino.rotate(self.direction, rotation)
		pass
	
	func move_vertical(y_change : int) -> bool:
		var move_vector : = Vector2(0, 1)
		if y_change < 0:
			move_vector = Vector2(0, -1)
			y_change = -y_change
			
		for i in y_change:
			if self.collides_on_pivot(self.pivot + move_vector):
				return true
			self.translate(move_vector)
			
		return false
		
	func move_horizontal(x_change : int) -> void:
		var move_vector : = Vector2(1, 0)
		if x_change < 0:
			move_vector = Vector2(-1, 0)
			x_change = -x_change
			
		for i in x_change:
			if self.collides_on_pivot(self.pivot + move_vector):
				return
			self.translate(move_vector)
	
	func collides_on_pivot(potential_pivot : Vector2) -> bool:
		# cells occupied by our tetromino now - don't return collision with self
		var occupied_cells : Array = self.occupied_cells()
		for potential_cell in self.occupied_cells_on_pivot(potential_pivot):
			if potential_cell in occupied_cells:
				continue
			if self.tile_map.get_cellv(potential_cell) != TileMap.INVALID_CELL:
				return true
		return false
	
	func translate(v : Vector2) -> void:
		self.erase()
		self.pivot += v
		self.draw()
	
	func erase():
		for occupied_cell in self.occupied_cells():
			self.tile_map.set_cellv(occupied_cell, TileMap.INVALID_CELL)

	func draw():
		for occupied_cell in self.occupied_cells():
			self.tile_map.set_cellv(occupied_cell, self.tile_id)
		
	func occupied_cells_on_pivot(potential_pivot : Vector2) -> Array:
		var translated_cells : Array = Tetromino.occupied_cells(self.type, self.direction)
		for i in translated_cells.size():
			translated_cells[i] += potential_pivot
		return translated_cells
	
	func occupied_cells() -> Array:
		return self.occupied_cells_on_pivot(self.pivot)

func _on_Timer_timeout():
	self.move_ticks += 1

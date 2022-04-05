extends TileMap

signal rows_removed(row_indexes, row_contents)

var active : ActiveTetro = null
var move_ticks : int = 0

func _process(_delta):
	if self.active == null:
		if self.move_ticks > 0:
			self.active = ActiveTetro.new(self, Tetromino.random_type())
			self.move_ticks = 0
		return

	var collision : bool = self.active.move_vertical(move_ticks)
	if collision:
		self.try_clear_rows()
		self.active = null
	
	self.move_ticks = 0

func try_clear_rows():
	var occupied_cells : = self.active.occupied_cells_on_pivot(self.active.pivot, self.active.direction)
	var rows_to_remove : Array
	for occupied_cell in occupied_cells:
		if is_row_full(occupied_cell.y) and not occupied_cell.y in rows_to_remove:
			rows_to_remove.append(occupied_cell.y)
			print("ROW %s COMPLETE"%occupied_cell.y)
	if len(rows_to_remove) == 0:
		return
			
	rows_to_remove.sort()
	signal_rows_removal(rows_to_remove)
	for row_to_remove in rows_to_remove:
		remove_row(row_to_remove)
	
func signal_rows_removal(removed_row_indexes : Array):
	var removed_row_contents = []
	for y in removed_row_indexes:
		# TODO: Const?
		for x in 10:
			removed_row_contents.append(self.get_cell(x, y))
	print("SIGNALING ROWS REMOVED: ", removed_row_indexes)
	emit_signal("rows_removed", removed_row_indexes, removed_row_contents)
			
func remove_row(y : int):
	for i in y:
		# TODO: Const?
		for x in 10:
			self.set_cell(x, y-i, self.get_cell(x, y-i-1))
	for x in 10:
			self.set_cell(x, 0, TileMap.INVALID_CELL)

func is_row_full(y : int) -> bool:
	# TODO: Const?
	for x in 10:
		if self.get_cell(x, y) == TileMap.INVALID_CELL:
			return false
	return true

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
			return
	if event.is_action_pressed("ui_rotate_clockwise"):
		if self.active != null:
			self.active.rotate(Tetromino.ROTATION.CLOCKWISE)
	if event.is_action_pressed("ui_rotate_counterclockwise"):
		if self.active != null:
			self.active.rotate(Tetromino.ROTATION.COUNTERCLOCKWISE)
	if event.is_action_pressed("ui_left"):
		if self.active != null:
			self.active.move_horizontal(-1)
	if event.is_action_pressed("ui_right"):
		if self.active != null:
			self.active.move_horizontal(1)
	if event.is_action_pressed("ui_down"):
		self.move_ticks += 1
	if event.is_action_pressed("ui_up"):
		# TODO: Highlight where collision would be.
		self.move_ticks += 100

class ActiveTetro:
	var tile_map : TileMap
	var tile_id : int
	
	var type : int
	var pivot : Vector2
	var direction : int
	
	func _init(tile_map : TileMap, type : int):
		self.tile_map = tile_map
		self.type = type
		self.tile_id = Tetromino.tile_for_type(type)
		self.pivot = Tetromino.starting_pivot_for_type(type)
		self.direction = Tetromino.DIRECTION.UP
		self.draw()
	
	func rotate(rotation : int) -> void:
		var next_direction : int = Tetromino.rotate(self.direction, rotation)
		if self.potentially_collides(self.pivot, next_direction):
			return
		self.erase()
		self.direction = next_direction
		self.draw()
	
	func move(step_vector : Vector2, steps : int) -> bool:
		if steps < 0:
			steps = -steps
			step_vector = -step_vector
		for i in steps:
			if self.potentially_collides(self.pivot + step_vector, self.direction):
				return true
			self.teleport(step_vector)
		return false
	
	func move_vertical(y_change : int) -> bool:
		return self.move(Vector2(0, 1), y_change)
		
	func move_horizontal(x_change : int) -> void:
		self.move(Vector2(1, 0), x_change)
	
	func potentially_collides(potential_pivot : Vector2, potential_direction : int) -> bool:
		# cells occupied by our tetromino now - don't return collision with self
		var current_cells : Array = self.occupied_cells_on_pivot(self.pivot, self.direction)
		for potential_cell in self.occupied_cells_on_pivot(potential_pivot, potential_direction):
			if potential_cell in current_cells:
				continue
			if self.tile_map.get_cellv(potential_cell) != TileMap.INVALID_CELL:
				return true
		return false
	
	func occupied_cells_on_pivot(potential_pivot : Vector2, potential_direction : int) -> Array:
		var translated_cells : Array = Tetromino.occupied_cells(self.type, potential_direction)
		for i in translated_cells.size():
			translated_cells[i] += potential_pivot
		return translated_cells
	
	func teleport(v : Vector2) -> void:
		self.erase()
		self.pivot += v
		self.draw()
	
	func erase():
		for occupied_cell in self.occupied_cells_on_pivot(self.pivot, self.direction):
			self.tile_map.set_cellv(occupied_cell, TileMap.INVALID_CELL)

	func draw():
		for occupied_cell in self.occupied_cells_on_pivot(self.pivot, self.direction):
			self.tile_map.set_cellv(occupied_cell, self.tile_id)

func _on_Timer_timeout():
	self.move_ticks += 1

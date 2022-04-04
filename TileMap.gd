extends TileMap

func _ready():
	spawn_tile()
	pass

func _process(delta):
	# TODO: Have a timer that triggers block moving down
	
	# TODO: When block hits the ground, freeze it in place
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
			return

	if event.is_action_pressed("ui_rotate_clockwise"):
		print("CLOCKWISE")
	if event.is_action_pressed("ui_rotate_counterclockwise"):
		print("COUNTERCLOCKWISE")
	if event.is_action_pressed("ui_left"):
		print("LEFT")
	if event.is_action_pressed("ui_right"):
		print("RIGHT")

func spawn_tile():
	var tetromino_type = Tetromino.random_type()
	var tetromino_direction = Tetromino.DIRECTION.UP
	var tetromino_pivot = Tetromino.pivot_for_type(tetromino_type)
	var tetromino_occupied_fields = Tetromino.occupied_cells(tetromino_type, tetromino_direction)
	pass

class ActiveTetro:
	var pivot : Vector2
	var type : int
	
	var current_direction : int
	var displayed_direction : int

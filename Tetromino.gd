extends Node

var rng := RandomNumberGenerator.new()

enum TYPE {O, I, S, Z, L, J, T}
enum DIRECTION {UP, RIGHT, DOWN, LEFT}
enum ROTATION {CLOCKWISE, COUNTERCLOCKWISE}
# Tiles have ids starting from 0 - I guess this might be a hack.
# Maybe some assertion on _ready?
enum TILE {RED, GREEN, PINK, BLUE, TEAL, YELLOW, BROWN}

func _ready():
	rng.randomize()
	print("random is random")

func random_type() -> int:
	var type_keys = TYPE.keys()
	return TYPE[type_keys[rng.randi() % type_keys.size()]]

func rotate(direction : int, rotation : int) -> int:
	match rotation:
		ROTATION.CLOCKWISE:
			return (direction + 1) % DIRECTION.size()
		ROTATION.COUNTERCLOCKWISE:
			if direction > 0:
				return direction - 1
			return DIRECTION.size() - 1
		_:
			push_error("invalid rotation %s"%rotation)
			assert(false)
			return -1

func starting_pivot_for_type(t : int) -> Vector2:
	match t:
		TYPE.O:
			return Vector2(4, 1)
		TYPE.I:
			return Vector2(4, 3)
		TYPE.S:
			return Vector2(5, 1)
		TYPE.Z:
			return Vector2(4, 1)
		TYPE.L:
			return Vector2(5, 1)
		TYPE.J:
			return Vector2(4, 1)
		TYPE.T:
			return Vector2(4, 1)
		_:
			push_error("unknown tetromino type: %s"%t)
			assert(false)
			return Vector2()

# occupied_cells return which tiles will be occupied relative to pivot
# when tile of type t is pointed in direction dir.
func occupied_cells(t : int, dir : int) -> Array:
	match t:
		TYPE.O:
			match dir:
				DIRECTION.UP:
					#  X X
					#  P X
					return [Vector2(0, -1), Vector2(1, -1), Vector2(0, 0), Vector2(0, 1)]
				DIRECTION.RIGHT:
					# P X
					# X X
					return [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]
				DIRECTION.DOWN:
					# X P
					# X X
					return [Vector2(-1, 0), Vector2(0, 0), Vector2(-1, 1), Vector2(0, 1)]
				DIRECTION.LEFT:
					# X X
					# X P
					return [Vector2(-1, -1), Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0)]
				_:
					push_error("unknown tetromino O direction: %s"%dir)
					assert(false)
					return []
		TYPE.I:
			match dir:
				DIRECTION.UP:
					# X
					# X
					# P
					# X
					return [Vector2(0, -2), Vector2(0, -1), Vector2(0, 0), Vector2(0, 1)]
				DIRECTION.RIGHT:
					# X P X X
					return [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)]
				DIRECTION.DOWN:
					# X
					# P
					# X
					# X
					return [Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2)]
				DIRECTION.LEFT:
					# X X P X
					return [Vector2(-2, 0), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)]
				_:
					push_error("unknown tetromino I direction: %s"%dir)
					assert(false)
					return []
		TYPE.S:
			match dir:
				DIRECTION.UP:
					# X
					# X P
					#   X
					return [Vector2(-1, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(0, 1)]
				DIRECTION.RIGHT:
					#   X X
					# X P  
					return [Vector2(0, -1), Vector2(1, -1), Vector2(-1, 0), Vector2(0, 0)]
				DIRECTION.DOWN:
					# X
					# P X
					#   X
					return [Vector2(0, -1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]
				DIRECTION.LEFT:
					#   P X
					# X X
					return [Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1)]
				_:
					push_error("unknown tetromino S direction: %s"%dir)
					assert(false)
					return []
		TYPE.Z:
			match dir:
				DIRECTION.UP:
					#   X
					# P X
					# X
					return [Vector2(-1, 1), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)]
				DIRECTION.RIGHT:
					# X P
					#   X X
					return [Vector2(-1, 0), Vector2(0, 0), Vector2(0, 1), Vector2(1, 1)]
				DIRECTION.DOWN:
					#   X
					# X P
					# X
					return [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(-1, 1)]
				DIRECTION.LEFT:
					# X X
					#   P X
					return [Vector2(-1, -1), Vector2(0, -1), Vector2(0, 0), Vector2(1, 0)]
				_:
					push_error("unknown tetromino Z direction: %s"%dir)
					assert(false)
					return []
		TYPE.L:
			match dir:
				DIRECTION.UP:
					# X
					# P
					# X X
					return [Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(1, 1)]
				DIRECTION.RIGHT:
					# X P X
					# X
					return [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1)]
				DIRECTION.DOWN:
					# X X
					#   P
					#   X
					return [Vector2(-1, -1), Vector2(0, -1), Vector2(0, 0), Vector2(0, 1)]
				DIRECTION.LEFT:
					#     X
					# X P X
					return [Vector2(1, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)]
				_:
					push_error("unknown tetromino L direction: %s"%dir)
					assert(false)
					return []
		TYPE.J:
			match dir:
				DIRECTION.UP:
					#   X
					#   P
					# X X
					return [Vector2(0, -1), Vector2(0, 0), Vector2(-1, 1), Vector2(0, 1)]
				DIRECTION.RIGHT:
					# X
					# X P X
					return [Vector2(-1, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)]
				DIRECTION.DOWN:
					# X X
					# P
					# X
					return [Vector2(0, -1), Vector2(1, -1), Vector2(0, 0), Vector2(0, 1)]
				DIRECTION.LEFT:
					# X P X
					#     X
					return [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]
				_:
					push_error("unknown tetromino J direction: %s"%dir)
					assert(false)
					return []
		TYPE.T:
			match dir:
				DIRECTION.UP:
					#   X
					# X P X
					return [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)]
				DIRECTION.RIGHT:
					# X
					# P X
					# X
					return [Vector2(0, -1), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)]
				DIRECTION.DOWN:
					# X P X
					#   X
					return [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)]
				DIRECTION.LEFT:
					#   X
					# X P
					#   X
					return [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(0, 1)]
				_:
					push_error("unknown tetromino T direction: %s"%dir)
					assert(false)
					return []
		_:
			push_error("unknown tetromino type: %s"%t)
			assert(false)
			return []

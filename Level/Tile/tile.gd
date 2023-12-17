extends StaticBody2D
class_name Tile

signal destroyed

@export var max_horizontal_variation : int = 5
@export var tile_size : int = 32

@onready var left_polygon : Polygon2D = $LeftWall
@onready var inner_polygon : Polygon2D = $InnerWall
@onready var right_polygon : Polygon2D = $RightWall
@onready var left_collision : CollisionPolygon2D = $LeftCollision
@onready var right_collision : CollisionPolygon2D = $RightCollision
@onready var inner_collision : CollisionPolygon2D = $InnerCollision

var left_pos = 0
var left_inner = 0
var right_inner = 0
var right_pos = 0
var has_middle = 0
var had_middle : bool = false
var is_spawn_something : bool = false

var is_forced_end_point : bool = false
var forced_end_left : int
var forced_end_right : int


func _process(_delta):
	if position.y > 1000 :
		destroyed.emit()
		queue_free()

func generate(_left_pos : int, _left_inner : int, _right_inner : int, _right_pos : int, _middle_begin : bool, _middle_end : bool):
	left_pos = _left_pos
	left_inner = _left_inner
	right_inner = _right_inner
	right_pos = _right_pos
	has_middle = _middle_begin
	had_middle = _middle_begin
	
	var polygon : Polygon2D
	var noise : Noise
	
	var left_points : Array[Vector2]
	var inner_left_points : Array[Vector2]
	var inner_right_points : Array[Vector2]
	var right_points : Array[Vector2]
	
	left_points.append(Vector2(0, 0))
	left_points.append(Vector2(0, 31))
	right_points.append(Vector2(160, 0))
	right_points.append(Vector2(160, 31))
	
	for pos_y in range(0, tile_size):
		if pos_y == (tile_size/2):
			has_middle = _middle_end
		
		var previous_left_size = left_inner - left_pos
		var previous_right_size = right_pos - right_inner
		
		if !has_middle:
		
			var left_size = randi_range(max(40, previous_left_size - max_horizontal_variation), 
			min(50, previous_left_size + max_horizontal_variation))
			var right_size = randi_range(max(40, previous_left_size - max_horizontal_variation), 
			min(50, previous_right_size + max_horizontal_variation))
			
			left_pos = 80 - left_size
			right_pos = 80 + right_size
			
			if is_forced_end_point:
				if pos_y < tile_size - 1:
					left_pos = lerp(left_pos, forced_end_left, 0.2)
					right_pos = lerp(right_pos, forced_end_right, 0.2)
				else:
					left_pos = forced_end_left
					right_pos = forced_end_right
			
			right_inner = 80
			left_inner = 80
		
		else:
			var left_middle_size = 80 - left_inner
			var right_middle_size = right_inner - 80
			
			var left_new_size = randi_range(min(20, left_middle_size + max_horizontal_variation), max(5, left_middle_size - max_horizontal_variation))
			var right_new_size = randi_range(min(20, right_middle_size + max_horizontal_variation), max(5, right_middle_size - max_horizontal_variation))
			
			left_inner = 80 - left_new_size
			right_inner = 80 + right_new_size
			
			var left_size = randi_range(max(40, previous_left_size - max_horizontal_variation), 
			min(50, previous_left_size + max_horizontal_variation))
			var right_size = randi_range(max(40, previous_right_size - max_horizontal_variation), 
			min(50, previous_right_size + max_horizontal_variation))
			
			left_pos = left_inner - left_size
			right_pos = right_inner + right_size
			
			inner_left_points.append(Vector2(left_inner, (tile_size - 1) - pos_y))
			inner_right_points.append(Vector2(right_inner, (tile_size - 1) - pos_y))
		
		left_points.append(Vector2(left_pos, (tile_size - 1) - pos_y))
		right_points.append(Vector2(right_pos, (tile_size - 1) - pos_y))
	
	left_polygon.polygon = left_points
	left_collision.polygon = left_points
	
	right_polygon.polygon = right_points
	right_collision.polygon = right_points
	inner_right_points.reverse()
	inner_left_points.append_array(inner_right_points)
	inner_polygon.polygon = inner_left_points
	inner_collision.polygon = inner_left_points
	print("test")
	
	if is_spawn_something:
		_spawn_something()

func set_color(color : Color):
	left_polygon.color = color
	inner_polygon.color = color
	right_polygon.color = color

func _spawn_something():
	if has_middle or had_middle:
		var location = randi_range(0, 2)
		match location:
			0: # left only
				_spawn_left()
			1:
				_spawn_right()
			2:
				_spawn_left()
				_spawn_right()
	else:
		_spawn_ignore_middle()
	

func _spawn_left():
	var enemy = load("res://Destructibles/Enemy/enemy.tscn").instantiate()
	add_child(enemy)
	enemy.position.y = -15
	enemy.position.x = left_pos + (left_inner - left_pos)/2

func _spawn_right():
	var enemy = load("res://Destructibles/Enemy/enemy.tscn").instantiate()
	add_child(enemy)
	enemy.position.y = -15
	enemy.position.x = right_inner + (right_pos - right_inner)/2

func _spawn_ignore_middle():
	var enemy = load("res://Destructibles/Enemy/enemy.tscn").instantiate()
	add_child(enemy)
	enemy.position.y = -15
	enemy.position.x = randi_range(left_pos + 5, right_pos - 5)

extends Node2D
class_name CheckpointTile

signal destroyed

@export var tile_size : int = 93

@onready var lower_tile : Tile = $LowerTile
@onready var upper_tile : Tile = $UpperTile
@onready var bridge_scene := preload("res://Destructibles/Bridge/bridge.tscn")

var left_pos = 0
var left_inner = 0
var right_inner = 0
var right_pos = 0
var has_middle = 0

func _process(_delta):
	if position.y > 1000 :
		destroyed.emit()
		queue_free()


func generate(_left_pos : int, _left_inner : int, _right_inner : int, _right_pos : int, _middle_begin : bool, _middle_end : bool, spawn_bridge : bool = false):
	lower_tile.is_forced_end_point = true
	lower_tile.forced_end_left = 60
	lower_tile.forced_end_right = 100
	lower_tile.generate(_left_pos, _left_inner, _right_inner, _right_pos, _middle_begin, false)
	
	_generate_walls()
	
	upper_tile.generate(60, 80, 80, 100, false, _middle_end)
	left_pos = upper_tile.left_pos
	left_inner = upper_tile.left_inner
	right_inner = upper_tile.right_inner
	right_pos = upper_tile.right_pos
	has_middle = upper_tile.has_middle
	
	if spawn_bridge:
		_spawn_bridge()

func _generate_walls():
	#left wall
	var left_polygon : Array[Vector2]
	left_polygon.append(Vector2(0, 0))
	left_polygon.append(Vector2(0, 32))
	left_polygon.append(Vector2(60, 32))
	left_polygon.append(Vector2(60, 0))
	$LeftWall/Polygon2D.polygon = left_polygon
	$LeftWall/CollisionPolygon2D.polygon = left_polygon
	#right wall
	var right_polygon : Array[Vector2]
	right_polygon.append(Vector2(100, 0))
	right_polygon.append(Vector2(100, 32))
	right_polygon.append(Vector2(160, 32))
	right_polygon.append(Vector2(160, 0))
	$RightWall/Polygon2D.polygon = right_polygon
	$RightWall/CollisionPolygon2D.polygon = right_polygon
	
func _spawn_bridge():
	var bridge = bridge_scene.instantiate()
	add_child(bridge)
	bridge.position.x = 60

func set_color(color : Color):
	$LeftWall/Polygon2D.color = color
	$RightWall/Polygon2D.color = color
	upper_tile.set_color(color)
	lower_tile.set_color(color)


func _on_checkpoint_area_body_entered(body):
	Utils.set_checkpoint.emit(self)

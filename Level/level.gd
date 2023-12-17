extends Node2D

@export var checkpoint_scene : PackedScene
@export var tile_scene : PackedScene
@export var tiles_to_spawn_before_checkpoint = 15
@export var tiles_variation_min := 0
@export var tiles_variation_max := 5
@export var prewarm_size : int = 20
@export var possible_colors : Array[Color]

@onready var loaded_checkpoint_scene = load(checkpoint_scene.resource_path)
@onready var loaded_tile_scene = load(str(tile_scene.resource_path))
@onready var tiles := $Tiles
@onready var lives_array = $CanvasLayer/MarginContainer/HBoxContainer/HB_lives

var speed : float = 50
var remaining_tiles : int = 0
var remaining_lives = 3
var current_color = 0
var score : int = 0

var last_check_point

func _ready():
	for i in range(0, prewarm_size):
		spawn_next()
	Utils.add_score.connect(update_score)
	Utils.set_checkpoint.connect(_set_checkpoint)
	$Player.died.connect(remove_life)

func _physics_process(delta):
	for node in tiles.get_children():
		node.position.y += speed * delta

func spawn_checkpoint(spawn_bridge : bool = false):
	var new_node = loaded_checkpoint_scene.instantiate()
	new_node.destroyed.connect(spawn_next)
	var pos_y : int = 192-30
	
	var left_pos : int = 50
	var left_inner : int = 80
	var right_inner : int = 80
	var right_pos : int = 120
	var begin_middle : bool = false
	var end_middle : bool = randf() > 0.5
	
	if tiles.get_child_count() > 0:
		var tile = tiles.get_child(tiles.get_child_count() - 1)
		pos_y = tile.position.y - (tile.tile_size -1)
		
		left_pos = tile.left_pos
		left_inner = tile.left_inner
		right_inner = tile.right_inner
		right_pos = tile.right_pos
		begin_middle = tile.has_middle
		end_middle = false if (!tile.has_middle and randf() > 0.75) or (tile.has_middle and randf() < 0.4) else true
	else:
		Utils.set_checkpoint.emit(new_node)
	tiles.add_child(new_node)
	new_node.position.y = pos_y
	new_node.generate(left_pos, left_inner, right_inner ,right_pos, begin_middle, end_middle, spawn_bridge)
	change_color()
	new_node.set_color(possible_colors[current_color])

func spawn_tile():
	var new_node = loaded_tile_scene.instantiate()
	new_node.destroyed.connect(spawn_next)
	new_node.is_spawn_something = true
	var pos_y : int = 192
	
	var left_pos : int = 50
	var left_inner : int = 80
	var right_inner : int = 80
	var right_pos : int = 120
	var begin_middle : bool = randf() > 0.5
	var end_middle : bool = randf() > 0.5
	
	if tiles.get_child_count() > 0:
		var tile  = tiles.get_child(tiles.get_child_count() - 1)
		pos_y = tile.position.y - (tile.tile_size -1)
		
		left_pos = tile.left_pos
		left_inner = tile.left_inner
		right_inner = tile.right_inner
		right_pos = tile.right_pos
		begin_middle = tile.has_middle
		end_middle = false if (!tile.has_middle and randf() > 0.75) or (tile.has_middle and randf() < 0.4) else true
		
	tiles.add_child(new_node)
	new_node.position.y = pos_y
	new_node.generate(left_pos, left_inner, right_inner ,right_pos, begin_middle, end_middle)
	new_node.set_color(possible_colors[current_color])

func spawn_next():
	if remaining_tiles == 0:
		spawn_checkpoint(tiles.get_child_count() > 0)
		remaining_tiles = randi_range(tiles_variation_min, tiles_variation_max)
		remaining_tiles += tiles_to_spawn_before_checkpoint
	else:
		spawn_tile()
		remaining_tiles -= 1

func change_color():
	var next_color = current_color
	while next_color == current_color:
		next_color = randi_range(0, possible_colors.size() - 1)
	current_color = next_color

func update_score(amount : int):
	score += amount
	$CanvasLayer/MarginContainer/HBoxContainer/HBoxContainer/Score.text = str(score)

func remove_life():
	$RespawnTimer.start()
	get_tree().paused = true
	remaining_lives -= 1
	
	for i in range(0, lives_array.get_child_count()):
		if(i < remaining_lives):
			lives_array.get_child(i).show()
		else:
			lives_array.get_child(i).hide()


func _set_checkpoint(tile :CheckpointTile):
	last_check_point = tile


func _on_respawn_timer_timeout():
	var checkpoint_distance = last_check_point.position.y - 150
	
	for child in tiles.get_children():
		child.position.y -= checkpoint_distance
	
	$Player.global_position = Vector2(80, last_check_point.global_position.y)
	get_tree().paused = false

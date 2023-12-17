extends CharacterBody2D

signal died

@export var horizontal_speed = 15

@onready var projectile_scene = preload("res://Player/projectile/player_bullet.tscn")

func _process(delta):
	var input : = Input.get_axis("ui_left", "ui_right")
	var motion = input * horizontal_speed * delta
	var collision = move_and_collide(Vector2(motion, 0))
	
	if collision:
		die()
	else:
		collision = move_and_collide(Vector2(0, -1), true)
		if collision:
			die()
	
	if Input.is_action_just_pressed("fire"):
		fire()


func die():
	died.emit()
	print("crash")

func fire():
	var new_bullet = projectile_scene.instantiate()
	$Bullets.add_child(new_bullet)
	new_bullet.global_position = $Muzzle.global_position

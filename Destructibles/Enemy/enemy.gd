extends "res://Destructibles/Destructible/Destructible.gd"

@export var speed = 5
var move_signal : int = -1

func _physics_process(delta):
	if $LeftCast.is_colliding() or $RightCast.is_colliding():
		$Sprite2D.flip_h = !$Sprite2D.flip_h
		move_signal *= -1
	
	position.x += move_signal * speed * delta

func _on_player_detection_body_entered(body):
	body.die()

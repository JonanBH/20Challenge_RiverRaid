extends Node2D
class_name Destructible

signal destroyed(int)

@export var health : int = 1
@export var base_score : int = 1

func _on_hurt_box_took_hit():
	health -= 1
	print("Destructible took hit")
	
	if health <= 0:
		destroyed.emit(base_score)
		Utils.add_score.emit(base_score)
		call_deferred("_die")

func _die():
	remove_child($HurtBox)
	$DespawnTimer.start()
	await($DespawnTimer.timeout)
	queue_free()


func _on_player_detection_body_entered(body):
	body.die()

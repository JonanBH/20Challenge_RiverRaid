extends Area2D

@export var speed = 3

func _physics_process(delta):
	position.y -= speed * delta

func _on_area_entered(area):
	queue_free()


func _on_body_entered(body):
	queue_free()

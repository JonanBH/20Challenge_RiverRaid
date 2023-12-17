extends Area2D

signal took_hit

func _on_area_entered(area):
	took_hit.emit()

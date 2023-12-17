extends Node2D

func _ready():
	$CheckpointTile.generate(50, 80, 80, 100, false, false)
	#$Tile.generate(50, 80, 80, 100, true, false)
	#$Tile2.generate($Tile.left_pos, $Tile.left_inner, $Tile.right_inner, $Tile.right_pos, $Tile.has_middle, true)

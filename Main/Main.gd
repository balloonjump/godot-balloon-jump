extends Node2D

func _ready():
	
	var ground_half_width   = $Ground.get_scaled_extents().x
	var ground_half_height  = $Ground.get_scaled_extents().y
	var player_half_width   = $Player.get_scaled_extents().x
	var player_half_height  = $Player.get_scaled_extents().y
	
	$Player.min_position_x  = $Ground.position.x - ground_half_width  + player_half_width
	$Player.max_position_x  = $Ground.position.x + ground_half_width  - player_half_width
	$Player.max_position_y = $Ground.position.y - ground_half_height - player_half_height
	
	print("Ground Scaled Extents = ", $Ground.get_scaled_extents())
	print("Player Scaled Extents = ", $Player.get_scaled_extents())
	print("Ready: Main")



func _process(delta):
	pass



extends Node2D

func _ready():
	
	# The Ground Determines the dimensions of the play area
	# which determines the min/max of the player's position.
	
	var ground_half_width   = $Ground.get_scaled_extents().x
	var ground_half_height  = $Ground.get_scaled_extents().y
	var player_half_width   = $Player.get_scaled_extents().x
	var player_half_height  = $Player.get_scaled_extents().y
	
	$Player.min_position_x  = $Ground.position.x - ground_half_width  + player_half_width
	$Player.max_position_x  = $Ground.position.x + ground_half_width  - player_half_width
	$Player.max_position_y  = $Ground.position.y - ground_half_height - player_half_height
	
	
	# The Ground will also determine where the camera limits are for now.
	# If other images are added to the sides of the play area, then this
	# will change.
	
	$Player/Camera2D.limit_left   = $Ground.position.x - ground_half_width
	$Player/Camera2D.limit_right  = $Ground.position.x + ground_half_width
	$Player/Camera2D.limit_bottom = $Ground.position.y + ground_half_height


func _process(delta):
	pass



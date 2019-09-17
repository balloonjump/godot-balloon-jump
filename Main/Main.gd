extends Node2D

export var first_balloon_y = -500
export var balloon_spacing_y_min = -100
export var balloon_spacing_y_max = -200

var Balloon = preload("res://Balloon/Balloon.tscn")

var next_balloon_y: int


func _ready():
	
	randomize()
	
	# ---------------------------------------------------------------------
	# Determine Play Area
	# ---------------------------------------------------------------------
	
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
	
	
	# ---------------------------------------------------------------------
	# When the Game Starts
	# ---------------------------------------------------------------------
	
	gamereset()



func gamereset():
	spawnInitialBallons()


func spawnInitialBallons():
	next_balloon_y = first_balloon_y
	var min_x = $Player.min_position_x
	var max_x = $Player.max_position_x
	for i in range(10):
		var bal = Balloon.instance()
		add_child(bal)
		bal.position.x = int(rand_range(min_x, max_x))
		bal.position.y = next_balloon_y
		next_balloon_y += int(rand_range(balloon_spacing_y_min, balloon_spacing_y_max))




# ---------------------------------------------------------------------
# Proccessing
# ---------------------------------------------------------------------


func _physics_process(delta: float) -> void:
	pass
	

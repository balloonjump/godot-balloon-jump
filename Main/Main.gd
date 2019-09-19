extends Node2D

export var first_balloon_y = -500
export var balloon_spacing_y_min = -200
export var balloon_spacing_y_max = -400

var Balloon = preload("res://Balloon/Balloon.tscn")

var next_balloon_y: int


var backgrounds: Array
var background_height: int


func _ready():
	
	# ---------------------------------------------------------------------
	# Seed the Random Number Generator
	# ---------------------------------------------------------------------
	
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


	var setting_string = "display/window/size/width"
	ProjectSettings.set_setting(setting_string, ground_half_width*2)
	if ProjectSettings.has_setting(setting_string):
		print(ProjectSettings.get_setting(setting_string))
	else:
		print("CANNOT FIND THE PROJECT SETTING: ", setting_string)
	
	# ---------------------------------------------------------------------
	# Init Background
	# ---------------------------------------------------------------------
	
	backgrounds = [
		get_node("background1"),
		get_node("background2"),
		get_node("background3"),
	]
	
	background_height = $background1.get_rect().size.y * $background1.scale.y
	
	$background1.position.y = $Player/Camera2D.limit_bottom - background_height
	$background2.position.y = $background1.position.y - background_height
	$background3.position.y = $background2.position.y - background_height
	
	# ---------------------------------------------------------------------
	# When the Game Starts
	# ---------------------------------------------------------------------
	
	gamereset()
	print_debug_background_positions()



func gamereset():
	spawnInitialBallons()


func spawnInitialBallons():
	next_balloon_y = first_balloon_y
	var min_x = $Player.min_position_x
	var max_x = $Player.max_position_x
	for i in range(30):
		var bal = Balloon.instance()
		add_child(bal)
		bal.position.x = int(rand_range(min_x, max_x))
		bal.position.y = next_balloon_y
		next_balloon_y += int(rand_range(balloon_spacing_y_min, balloon_spacing_y_max))




# ---------------------------------------------------------------------
# Proccessing
# ---------------------------------------------------------------------

class MyCustomSorter:
    static func sort(a, b):
        if a.position.y > b.position.y:
            return true
        return false


func _process(delta: float) -> void:
	if $Player.position.y < (backgrounds[1].position.y):
		backgrounds[0].position.y -= background_height * 3
		backgrounds.sort_custom(MyCustomSorter, "sort")
		print("backgrounds: move UP")
		# print_debug_background_positions()
		
	if $Player.position.y > (backgrounds[1].position.y + background_height):
		backgrounds[2].position.y += background_height * 3
		backgrounds.sort_custom(MyCustomSorter, "sort")
		print("backgrounds: move DOWN")
		# print_debug_background_positions()

func _physics_process(delta: float) -> void:
	pass
	


func print_debug_background_positions():
	print(
		"backgrounds: positions: [",
		backgrounds[0].position.y, ", ",
		backgrounds[1].position.y, ", ",
		backgrounds[2].position.y, "]"
	)
	# print("background height = ", background_height)
	
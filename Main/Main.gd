extends Node2D

export var first_balloon_y = -500
export var balloon_spacing_y_min = -200
export var balloon_spacing_y_max = -400

export var GUI_NODE_PATH: NodePath

onready var gui = get_node(GUI_NODE_PATH)
onready var camera = get_node("Camera2D")

const Balloon = preload("res://Balloon/Balloon.tscn")

var next_balloon_y: int
var current_score : int = 0

const DISTANCE_BETWEEN_NEWEST_BALLOON_AND_SPAWN_LINE := 5000
const DISTANCE_BETWEEN_PLAYER_AND_RESET_LINE := 800
var reset_line := DISTANCE_BETWEEN_PLAYER_AND_RESET_LINE


# variables used to automatically place the background images.
var backgrounds: Array
var background_height: int
var players_current_background_region: int = 0

func _ready():
	
	# ---------------------------------------------------------------------
	# Seed the Random Number Generator
	# ---------------------------------------------------------------------
	
	randomize()
	
	# ---------------------------------------------------------------------
	# Determine Play Area
	# ---------------------------------------------------------------------
	
	var max_x = ProjectSettings.get_setting("display/window/size/width")
	
	# The Ground Determines the dimensions of the play area
	# which determines the min/max of the player's position.
	
	var ground_half_width   = $Ground.get_scaled_extents().x
	var ground_half_height  = $Ground.get_scaled_extents().y
	var player_half_width   = $Player.get_scaled_extents().x
	var player_half_height  = $Player.get_scaled_extents().y
	
	# $Player.min_position_x  = $Ground.position.x - ground_half_width  + player_half_width
	# $Player.max_position_x  = $Ground.position.x + ground_half_width  - player_half_width
	$Player.max_position_y  = $Ground.position.y - ground_half_height - player_half_height
	$Player.max_position_x = max_x
	$Player.min_position_x = 0
	
	
	# The Ground will also determine where the camera limits are for now.
	# If other images are added to the sides of the play area, then this
	# will change.
	
	# camera.limit_left   = $Ground.position.x - ground_half_width
	# camera.limit_right  = $Ground.position.x + ground_half_width
	camera.limit_bottom = $Ground.position.y + ground_half_height
	
	camera.limit_left = 0
	camera.limit_right = max_x

	# ---------------------------------------------------------------------
	# Init Background
	# ---------------------------------------------------------------------
	
	backgrounds = [
		get_node("background1"),
		get_node("background2"),
		get_node("background3"),
	]
	
	background_height = $background1.get_rect().size.y * $background1.scale.y
	
	# $background1.position.y = $Player/Camera2D.limit_bottom - background_height
	$background2.position.y = $background1.position.y - background_height
	$background3.position.y = $background2.position.y - background_height
	
	# ---------------------------------------------------------------------
	# When the Game Starts
	# ---------------------------------------------------------------------
	
	gamereset()
	#print_debug_background_positions()



# --------------------------------------------------------------------------
# Balloon Spawning and Game Restarting
# --------------------------------------------------------------------------

const DEFAULT_NUMBER_OF_BALLOONS_TO_GENERATE := 10
var number_of_balloons_generated := DEFAULT_NUMBER_OF_BALLOONS_TO_GENERATE

func gamereset():
	# print("game reset!")
	reset_line = DISTANCE_BETWEEN_PLAYER_AND_RESET_LINE
	$Player.position.y = 0
	var children = get_children()
	for child in children:
		if child.is_in_group("balloon"):
			remove_child(child)
	spawnInitialBallons()
	number_of_balloons_generated = DEFAULT_NUMBER_OF_BALLOONS_TO_GENERATE
	# debug_print_bal_count()


func spawnInitialBallons():
	next_balloon_y = first_balloon_y
	for i in range(30):
		spawnNewRandomBalloon()


func spawnNewRandomBalloon():
	var min_x = $Player.min_position_x
	var max_x = $Player.max_position_x
	var x: int = int(rand_range(min_x, max_x))
	var y: int = next_balloon_y
	spawnBalloonAt(x, y)
	next_balloon_y += int(rand_range(balloon_spacing_y_min, balloon_spacing_y_max))


func spawnBalloonAt(x, y):
	var bal = Balloon.instance()
	add_child(bal)
	bal.position.x = x
	bal.position.y = y
	bal.scale = Vector2(0.75, 0.75)


func processBalloonSpawner():
	var y: int = next_balloon_y + DISTANCE_BETWEEN_NEWEST_BALLOON_AND_SPAWN_LINE
	$LoonLine.position.y = y
	if $Player.position.y < y:
		spawnNewRandomBalloon()
		number_of_balloons_generated += 1
		# debug_print_bal_count()


func debug_print_bal_count():
	print("bal count = ", number_of_balloons_generated)

# ---------------------------------------------------------------------
# Proccessing
# ---------------------------------------------------------------------

func _process(delta: float) -> void:
	
	reset_line = min(reset_line, $Player.position.y + DISTANCE_BETWEEN_PLAYER_AND_RESET_LINE)
	$DeathLine.position.y = reset_line
	
	for child in get_children():
		if child.is_in_group("balloon") and child.position.y > reset_line:
			remove_child(child)
	
	processBalloonSpawner()
	
	if $Player.position.y > reset_line:
		gamereset()
	
	update_background_positions()
	
	current_score = -floor($Player.position.y / 1000) - 1
	gui.set_score(current_score)


func _physics_process(delta):
	
	# check to make sure there are starter balloons near the beginning,
	# reset the game if the player has managed to lose their starter balloons.
	if $Player.position.y > (-150):
		var starter_ballon_exists = false
		for child in get_children():
			if child.is_in_group("balloon") and child.position.y > -700:
				starter_ballon_exists = true
				break
		if !starter_ballon_exists:
			gamereset()


func print_debug_background_positions():
	print(
		"backgrounds: positions: [",
		backgrounds[0].position.y, ", ",
		backgrounds[1].position.y, ", ",
		backgrounds[2].position.y, "]"
	)
	
	
func update_background_positions():
	var background_region: int = $Player.position.y / background_height
	if (players_current_background_region != background_region):
		players_current_background_region = background_region
		for i in range(3):
			backgrounds[i].position.y = background_height * (background_region - i)
		#print("background region:", background_region)
		#print_debug_background_positions()

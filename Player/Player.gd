extends Node2D

# ================================================
# Variables
# ================================================

var speed_y_jumping = 20
var speed_y_falling = 15
var speed_x = 10

# Maximum Positions are changed by Main.gd when the game starts,
# they are determined by the "Ground" object, which defines the
# playable area for the player.

var min_position_x = 0
var max_position_x = 1000
var max_position_y = 0

# Collision Variables, changed when the player is colliding with
# a balloon string.

var the_balloon_im_holding: Area2D
var the_balloon_i_jumped_from: Area2D
var jump_used_up = false

# Cooldowns
# When a cooldown is 0, it has already finished "cooling"
# Anything above 0 is considered "hot".
# Each of the cooldowns is decremented by 1 per physics frame. 

var cooldowns = {
	after_grab_ends = 0,
	after_grab_begins = 0,
}


# ================================================
# Public Functions
# ================================================
# Even though godot lets you call any function you want to, 
# these are the functions that are specifically designed for
# public usage.

func get_scaled_extents():
	return $CollisionShape2D.shape.extents * transform.get_scale()



# ================================================
# Main Functions
# ================================================

func _ready():
	position.y = max_position_y
	_state_machine_ready()
	
func _process(delta):
	_process_sideways_movement(delta)


func _physics_process(delta):
	_state_machine_process()
	for k in cooldowns.keys():
		if cooldowns[k] > 0: 
			cooldowns[k] -= 1


# ================================================
# Movement along the X axis
# ================================================

# TODO: MOVE THESE INTO THE STATE MACHINE WHEN IT MAKES SENSE! 

func _process_sideways_movement(delta):
	var curr_speed = 0
	if cooldowns.after_grab_begins > 5:
		return
	if Input.is_action_pressed("ui_right"):
		curr_speed += speed_x
		$AnimatedSprite.flip_h = false
	if Input.is_action_pressed("ui_left"):
		curr_speed -= speed_x
		$AnimatedSprite.flip_h = true
	position.x += curr_speed * delta * 60
	position.x = clamp(position.x, min_position_x, max_position_x)


# ================================================
# State Machine 
# ================================================

var _current_state = STATE_STANDING
var _next_state = STATE_STANDING

enum {
	STATE_STANDING,
	STATE_JUMPING,
	STATE_FALLING,
	STATE_GRABBING,
}

var _stateFunctions = {
	STATE_STANDING: _make_state_function_set("standing"),
	STATE_JUMPING: _make_state_function_set("jumping"),
	STATE_FALLING: _make_state_function_set("falling"),
	STATE_GRABBING: _make_state_function_set("grabbing"),
}

func _make_state_function_set(name):
	return {
		enter  = funcref(self, "_state_%s_enter" % name),
		update = funcref(self, "_state_%s_update" % name),
		exit   = funcref(self, "_state_%s_exit" % name),
	}


func _state_machine_ready():
	_stateFunctions[_current_state].enter.call_func()


func _state_machine_process():
	_stateFunctions[_current_state].update.call_func()
	_state_machine_late_process()
	if (_current_state != _next_state):
		_stateFunctions[_current_state].exit.call_func()
		_current_state = _next_state
		_stateFunctions[_current_state].enter.call_func()
	
	


# ================================================
# Transitions from Any State
# ================================================

func _state_machine_late_process():
	if position.y > (max_position_y + 1):
		position.y = max_position_y
		_next_state = STATE_STANDING
	if (
		_current_state != STATE_GRABBING
		and cooldowns.after_grab_ends <= 0
		and the_balloon_im_holding != null
		and the_balloon_im_holding != the_balloon_i_jumped_from
	):
		_next_state = STATE_GRABBING


# ================================================
# State: Standing
# ================================================

func _state_standing_enter():
	$AnimatedSprite.animation = "default"
	jump_used_up = false
	
	
func _state_standing_update():
	if Input.is_action_pressed("ui_up"):
		_next_state = STATE_JUMPING
	
	
func _state_standing_exit():
	pass



# ================================================
# State: Jumping
# ================================================

var _state_jumping_counter_max = 25
var _state_jumping_counter = 0


func _state_jumping_enter():
	$AnimatedSprite.animation = "jump"
	_state_jumping_counter = 0
	jump_used_up = true

	
func _state_jumping_update():
	if (Input.is_action_pressed("ui_up") and (_state_jumping_counter < _state_jumping_counter_max)):
		_state_jumping_counter += 1
		position.y -= speed_y_jumping
	else:
		_next_state = STATE_FALLING


func _state_jumping_exit():
	pass


# ================================================
# State: Falling
# ================================================

var _state_falling_counter = 0

func _state_falling_enter():
	# $AnimatedSprite.animation = "falling"
	_state_falling_counter = 0

func _state_falling_update():
	_state_falling_counter += 1
	position.y += speed_y_falling
	if (
		Input.is_action_pressed("ui_up")
		and not jump_used_up
	):
		_next_state = STATE_JUMPING


func _state_falling_exit():
	pass


# ================================================
# State: Grabbing
# ================================================

func _state_grabbing_enter():
	$AnimatedSprite.animation = "grab"
	cooldowns.after_grab_begins = 10
	jump_used_up = false


func _state_grabbing_update():
	if (
		the_balloon_im_holding == null
		or not the_balloon_im_holding.overlaps_area(self.get_node("."))
	):
		_next_state = STATE_FALLING
	
	if (
		Input.is_action_pressed("ui_up")
		and cooldowns.after_grab_begins <= 0
	):
		the_balloon_i_jumped_from = the_balloon_im_holding
		_next_state = STATE_JUMPING


func _state_grabbing_exit():
	the_balloon_im_holding = null
	cooldowns.after_grab_ends = 5



# ================================================
# Signal Callbacks
# ================================================

func _on_Player_area_entered(area: Area2D) -> void:
	if "balloon" in area.get_groups():
		the_balloon_im_holding = area


func _on_Player_area_exited(area: Area2D) -> void:
	if area == the_balloon_i_jumped_from:
		the_balloon_i_jumped_from = null 



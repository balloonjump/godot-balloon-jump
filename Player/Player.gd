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


func get_scaled_extents():
	return $CollisionShape2D.shape.extents * transform.get_scale()


# ================================================
# Main Functions
# ================================================

func _ready():
	position.y = max_position_y
	_state_machine_ready()
	print("Ready: Player")


func _physics_process(delta):
	_state_machine_process()
	_process_sideways_movement()


# ================================================
# Movement along the X axis
# ================================================

# TODO: MOVE THESE INTO THE STATE MACHINE WHEN IT MAKES SENSE! 

func _process_sideways_movement():
	if Input.is_action_pressed("ui_right"):
		position.x += speed_x
	if Input.is_action_pressed("ui_left"):
		position.x -= speed_x
	position.x = clamp(position.x, min_position_x, max_position_x)


# ================================================
# State Machine 
# ================================================

enum {
	STATE_STANDING,
	STATE_JUMPING,
	STATE_FALLING,
}

var _current_state = STATE_STANDING
var _next_state = STATE_STANDING

var _stateFunctions = {
	STATE_STANDING: _make_state_function_set("standing"),
	STATE_JUMPING: _make_state_function_set("jumping"),
	STATE_FALLING: _make_state_function_set("falling"),
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


# ================================================
# State: Standing
# ================================================

func _state_standing_enter():
	$AnimatedSprite.animation = "default"
	
	
func _state_standing_update():
	if Input.is_action_pressed("ui_up"):
		_next_state = STATE_JUMPING
	
	
func _state_standing_exit():
	pass



# ================================================
# State: Jumping
# ================================================

export var _state_jumping_counter_max = 30
var _state_jumping_counter = 0


func _state_jumping_enter():
	$AnimatedSprite.animation = "jump"
	_state_jumping_counter = 0

	
func _state_jumping_update():
	if (Input.is_action_pressed("ui_up") and (_state_jumping_counter < _state_jumping_counter_max)):
		_state_jumping_counter += 1
		position.y -= speed_y_jumping
	else:
		_next_state = STATE_FALLING


func _state_jumping_exit():
	print("JUMP ^^^ = ", _state_jumping_counter)


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
	
func _state_falling_exit():
	print("fall down counter = ", _state_falling_counter)


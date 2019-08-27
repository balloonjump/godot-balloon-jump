extends Node2D

const pixels_per_unit_speed = 400
const max_jump_counter = 40
var gravity = 3
var sideways_speed = 3
var jump_speed = 5
var jump_counter = 0
var jump_cooldown = 0
var jump_used = false
var screen_size
var player_height
var player_width


func _ready():
	screen_size = get_viewport_rect().size
	player_height = $RigidBody2D/CollisionShape2D.shape.extents.y
	player_width = $RigidBody2D/CollisionShape2D.shape.extents.x


func _physics_process(delta):
	var v = Vector2()
	if Input.is_action_pressed("ui_right"):
		v.x += 1
	if Input.is_action_pressed("ui_left"):
		v.x -= 1
	if Input.is_action_pressed("ui_down"):
		v.y += 1
	if Input.is_action_pressed("ui_up"):
		v.y -= calculate_jump_velocity()
	v.x *= sideways_speed
	v.y += gravity
	v *= pixels_per_unit_speed
	position += v * delta
	position.x = clamp(position.x, player_width/2, screen_size.x)
	if position.y > -player_height/2:
		position.y = -player_height/2
		jump_used = false
	if jump_counter > 0: jump_counter -= 1
	if jump_cooldown > 0: jump_cooldown -= 1


func calculate_jump_velocity() -> int:
	if jump_counter == 0 and jump_cooldown == 0 and jump_used == false:
		jump_used = true
		jump_counter = max_jump_counter
		jump_cooldown = 20
	if jump_counter > 20:
		return jump_speed + 1
	if jump_counter > 0:
		return jump_speed
	return 0
	
	
	
	
	
tool
extends Area2D

class_name Balloon

var rising_speed = 10
var activated = false
var is_marked_for_deletion = false

signal freed()

func _ready():
	_draw()


func set_float_up_time(wait_time: int) -> void:
	$FloatUpTimer.wait_time = wait_time


func activate_balloon() -> void:
	if !activated:
		activated = true
		$FloatUpTimer.start()


func get_current_speed() -> int:
	# Returns the actual speed of the balloon so that a player can
	# rise along with it.  Returns 0 if the baloon is static.
	if activated:
		return rising_speed
	return 0


func _draw() -> void:
	# Manually Draw the Balloon String.
	draw_line(
		Vector2(0, 0),
		Vector2(0, 200),
		Color(0.0, 0.0, 0.0),
		8,
		true
	)


func _physics_process(delta: float) -> void:
	if activated:
		position.y -= rising_speed
	if is_marked_for_deletion:
		queue_free()


func _on_FloatUpTimer_timeout() -> void:
	$Top.animation = "popped"
	$AfterPopTimer.start()


func _on_AfterPopTimer_timeout() -> void:
	emit_signal("freed")
	is_marked_for_deletion = true



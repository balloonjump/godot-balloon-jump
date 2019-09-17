tool
extends Area2D

var balloon_radius = 100
var string_length = 300
var stroke_width = 8


func _ready() -> void:
	pass


func _draw() -> void:
	_drawBalloonString()
	_drawRegularBalloon()


func _drawBalloonString() -> void:
	var from = Vector2(0, 0)
	var to = Vector2(0, string_length)
	var color = Color(0.0, 0.0, 0.0)
	draw_line(from, to, color, stroke_width)


func _drawRegularBalloon() -> void:
	
	# Draw Outline of Balloon
	draw_circle(
		Vector2(0.0, 0.0),
		balloon_radius,
		Color(0.0, 0.0, 0.0)
	)
	
	# Draw Inside of Balloon
	draw_circle(
		Vector2(0.0, 0.0),
		balloon_radius - stroke_width,
		Color(1.0, 0.0, 0.0)
	)


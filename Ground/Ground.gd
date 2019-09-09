extends Node2D

func _ready() -> void:
	print("Ready: Ground")


func get_scaled_extents() -> Vector2:
	return $StaticBody2D/CollisionShape2D.shape.extents * transform.get_scale()


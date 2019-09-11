extends Node2D

func _ready():
	print("Ready: Ground")


func get_scaled_extents() -> Vector2:
	return $CollisionShape2D.shape.extents * transform.get_scale()


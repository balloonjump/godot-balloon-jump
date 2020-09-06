extends Camera2D

# Node that the camera will track the position of.
export var node_to_follow : NodePath
onready var follow = get_node(node_to_follow)

func _process(delta):
	position = follow.position

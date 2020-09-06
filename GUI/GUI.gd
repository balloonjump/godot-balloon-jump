extends MarginContainer

onready var score_number = get_node("HBoxContainer/Score/ScoreNumber")

func set_score(val):
	score_number.text = str(val)


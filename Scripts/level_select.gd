extends Control

func _ready() -> void:
	GameManager.level_select = self
	show()

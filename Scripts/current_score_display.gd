extends Label

func _process(_delta: float) -> void:
	text = str("Score: ", GameManager.score)

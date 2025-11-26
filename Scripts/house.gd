extends Node2D

var has_gift: bool = false

func receive_gift() -> void:
	if has_gift == true:
		pass
		#fail / overfilled
	else:
		has_gift = true
		# should update score in gameManager
		GameManager.add_point()

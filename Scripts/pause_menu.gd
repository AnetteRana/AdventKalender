extends Control

func resume():
	get_tree().paused = false
	
func pause():
	get_tree().paused = true

func testPauseInput():
	if Input.is_action_just_pressed("Pause") and !get_tree().paused:
		pause()
	if Input.is_action_just_pressed("Pause") and get_tree().paused:
		resume()


func _on_button_resume_pressed() -> void:
	resume()


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		pass # Replace with function body.
		# mute audio
	else:
		pass
		#TODO: unmute audio

func _process(delta: float) -> void:
	testPauseInput()

extends Control

var currentWasted: String ="?"
var currentTime: String ="?"
var bestWasted: String ="?"
var bestTime: String ="?"

func _ready() -> void:
	_centerMe()
	setVisible(false)
	GameManager.score_display = self
	SaveManager.score_display = self
	
func _centerMe():
	global_position = get_viewport_rect().size *0.5

#called by SaveManager:
func update_score_display(level_id: String, c_fewest: String, c_time: String, b_fewest: String, b_time: String):
	$VBoxContainer/VBox_current/HBoxContainer/wasted.text = c_fewest
	$VBoxContainer/VBox_current/HBoxContainer2/time.text = c_time
	$VBoxContainer/VBox_best/HBoxContainer/wasted.text = b_fewest
	$VBoxContainer/VBox_best/HBoxContainer2/time.text = b_time

func setVisible(newState: bool):
	visible = newState
	
	# set values
	#bestTime = SaveManager.get_level_bestTime()
	#$VBoxContainer/VBox_current/HBoxContainer/wasted.text = currentWasted
	#$VBoxContainer/VBox_current/HBoxContainer2/time.text = currentTime
	#$VBoxContainer/VBox_best/HBoxContainer/wasted.text = bestWasted
	#$VBoxContainer/VBox_best/HBoxContainer2/time.text = bestTime
	

func _on_button_pressed() -> void:
	setVisible(false)

extends Control

@export var level_num: int
@export var level_name: String = "Julebyen"
var level_ID: String # based in level_num
@export var unlock_date: String = "2025-12-01"  # format YYYY-MM-DD
@export var audio_clicked: AudioStream = preload("res://Assets/Audio/3Bells.wav")
@onready var button: Button = $Button

@onready var infoPanelCTRL: Control = get_parent().get_node("InfoPanel")

func _setID():
	level_ID = str(level_num)
	if level_ID.length()==1:
		level_ID = "0"+level_ID

func _ready():
	_setID()
	$Label.text = level_name
	var now = Time.get_datetime_dict_from_system()
	var todays_date = "%04d-%02d-%02d" % [now.year, now.month, now.day]

	if todays_date < unlock_date: # Locked
		button.disabled = true
		button.text = str(level_num)#"Locked until %s" % [unlock_date]
	else: # Unlocked
		button.disabled = false
		button.text = str(level_num)

	#infoPanelCTRL = get_tree().get_first_node_in_group("info_panel")
	button.pressed.connect(_on_pressed)

func _on_pressed(): #only when enabled
	if GameManager.isGameplayMode:
		return
		
	GameManager.isGameplayMode = true
	if not button.disabled and _getLevelPath() != "":
		_playAudio()
		await get_tree().create_timer(1.0).timeout #TODO better delay (signal based), transition screen

		# tell main to load_level(level_num):
		#var levelContainer = get_parent().get_parent().get_child(0)
		GameManager.load_level(level_num)
		#var scenenene = get_tree().current_scene
		#scenenene.load_level(level_num)
		get_parent().hide() # hide LevelSelect

func _playAudio(): #TODO: make an audio manager instead
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = audio_clicked
	player.play()

func _getLevelPath() -> String:
		var level_num_str: String = str(level_num)
		if level_num_str.length()==1:
			level_num_str = "0"+level_num_str
		return "res://Levels/Level_" + level_num_str + ".tscn"

func _on_button_mouse_entered() -> void:
	if infoPanelCTRL:
		#infoPanelCTRL.visible =true
		infoPanelCTRL.update_info(level_ID)

func _on_button_mouse_exited() -> void:
	if infoPanelCTRL:
		infoPanelCTRL.visible = false

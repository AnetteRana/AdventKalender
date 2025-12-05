extends Control

var offset = Vector2(16, 16)        # space between cursor and panel

func _ready() -> void: #add_to_group("info_panel")
	add_to_group("info_panel")

func _process(_delta): #follow cursor if visible
	if visible:
		follow_cursor()

func follow_cursor():
	var vp = get_viewport_rect()

	# target position = mouse + offset
	var pos = get_global_mouse_position() + offset
	#var size = get_size()           # panel size

	# clamp so the panel stays inside screen
	if pos.x + size.x > vp.size.x:
		pos.x = vp.size.x - size.x
	if pos.y + size.y > vp.size.y:
		pos.y = vp.size.y - size.y

	# optional clamp on left/up side
	if pos.x < 0:
		pos.x = 0
	if pos.y < 0:
		pos.y = 0

	global_position = pos

func update_info(level_id: String): # called by active AND inactive buttons on hover#
	if SaveManager.get_level_wastedGifts(level_id) == "inf":
		return
	else:
		$MarginContainer/HBoxContainer/VBoxContainer/Label_giftsMissed.text = SaveManager.get_level_wastedGifts(level_id)
		$MarginContainer/HBoxContainer/VBoxContainer/Label_timeSpent.text = SaveManager.get_level_bestTime(level_id)
		self.visible = true

func _on_button_pressed() -> void:
	pass # Replace with function body.

extends Control

var offset = Vector2(16, 16)        # space between cursor and panel

func _ready() -> void:
	add_to_group("info_panel")

func _process(_delta):
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

func update_info(level_id: int): # called by active AND inactive buttons
	print("updating info...")
#
	#var levelNumStr := str(level_id)
#
	## Safe access even if there's no save file yet
	#var save : Dictionary = Global.game_manager.save_data_cache
	#var levels: Dictionary = save.get("levels", {})
#
	#var data: Dictionary = levels.get(levelNumStr, {})
#
	#if data == null:
		#$VBoxContainer/Label_name.text = "Level " + levelNumStr
		#$VBoxContainer/Label_giftsMissed.text = "No data yet"
		#$VBoxContainer/Label_timeSpent.text = "-"
		#return
#
	#var bestTime = data.get("bestTime", 0.0)
	#var fewest   = data.get("fewest", 0)
	#
	#print(bestTime)
			## set visibility
	#if bestTime != 0.0:
		#self.visible = true
#
	#$VBoxContainer/Label_name.text = "Level " + levelNumStr
	#$VBoxContainer/Label_giftsMissed.text = "Gifts missed " + str(int(fewest))
	#$VBoxContainer/Label_timeSpent.text = "%.1f s" % float(bestTime)

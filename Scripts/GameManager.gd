extends Node

var level_container: Node2D
var level_select: Control
var score_display: Control

var current_level: Node

# for gameplay loop
var currentLevelID: String
var currentHousesInLevel: int
var current_housesFilled: int = 0 
var current_giftsUsed: int = 0
var level_time : float = 0.0
var tracking: bool = false

func _process(delta):
	if tracking:
		level_time += delta

func _on_house_filled():
	current_housesFilled += 1
	
	# check if finished
	current_level = level_container.get_child(0)
	#currentLevelResource = current_level.level_data	
	if current_housesFilled >= currentHousesInLevel:
		_on_level_finish()
	else:
		pass#print("current_housesFilled: " + str(current_housesFilled))

func _on_gift_thrown(): # from playerScript
	current_giftsUsed += 1
	print(str(current_giftsUsed))

func _on_level_finish():
	tracking = false #stop counting time 
	
	current_level = level_container.get_child(0)
	var wastedGifts: int = current_giftsUsed - current_housesFilled
	SaveManager.update_score(currentLevelID, wastedGifts, level_time)
	
	await get_tree().create_timer(0.4).timeout
	
# evaluate and save score TODO:(show score screen really...)
	
	# show score screen
	score_display.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
# return level select menu 
	level_select.show() 
# remove level
	current_level.queue_free()

#on p
#if not paused:
# pause game
#bring up ui

func load_level(levelNum: int):
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	current_housesFilled = 0
		
	var path = _getLevelPath(levelNum)
	#load new level
	var packed = load(path)
	if not packed:
		return

	var inst = packed.instantiate()
	level_container.add_child(inst)
	tracking = true
	

# connect all houses in this level
	for House in get_tree().get_nodes_in_group("house"):
		if inst.is_ancestor_of(House):  # only houses in this level
			House._on_house_filled.connect(_on_house_filled)
	
	var sleigh = inst.get_node("PlayerCharacter/Sleigh")
	sleigh._on_gift_thrown.connect(_on_gift_thrown)

func _getLevelPath(level_num: int) -> String:
		var level_num_str: String = str(level_num)
		if level_num_str.length()==1:
			level_num_str = "0"+level_num_str
		return "res://Levels/Level_" + level_num_str + ".tscn"

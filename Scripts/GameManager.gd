extends Node

#@onready var level_container = $LevelContainer
@export var level_container: Node2D

var current_level: Node = null
var currentLevelResource: levelResource

var current_housesFilled: int = 0 
var current_giftsUsed: int = 0

var level_time : float = 0.0
var tracking: bool = false

var save_data_cache = {} 

func _ready():
	Global.game_manager = self
	load_save()

func _process(delta):
	if tracking:
		level_time += delta

func _on_house_filled():
	current_housesFilled += 1
	
	# check if finished
	current_level = level_container.get_child(0)
	currentLevelResource = current_level.level_data	
	if current_housesFilled >= currentLevelResource.numberOfHouses:
		_on_level_finish()
		
	else:
		pass#print("current_housesFilled: " + str(current_housesFilled))

func _on_gift_thrown(): # from playerScript
	current_giftsUsed += 1
	print(str(current_giftsUsed))

func _on_level_finish():
	tracking = false #stop time 
	
	current_level = level_container.get_child(0)
	var wastedGifts: int = current_giftsUsed - current_housesFilled
	update_score(str(currentLevelResource.levelNumber), wastedGifts, level_time)
	
	await get_tree().create_timer(0.4).timeout
	
# evaluate and save score TODO:(show score screen really...)
	
# return level select menu
	$LevelSelect.show() 

# remove level
	current_level.queue_free()

#on p
#if not paused:
# pause game
#bring up ui

func load_level(levelNum: int):
	# clear old level
	#for child in level_container.get_children():
		#child.queue_free()
		
	current_housesFilled = 0
		
	var path = _getLevelPath(levelNum)
	#load new level
	var packed = load(path)
	if not packed:
		return

	var inst = packed.instantiate()
	level_container.add_child(inst)
	tracking = true
	
	currentLevelResource = inst.level_data

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

# save handling
func load_save() -> Dictionary:
	var file = FileAccess.open("res://Data/SaveData.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var parsed = JSON.parse_string(text)
		save_data_cache = parsed

		if typeof(parsed) == TYPE_DICTIONARY:
			return parsed

		# if file exists but broken
		return {"levels": {}}

	# if no file found
	return {"levels": {}}


func save_data(data):
	var file = FileAccess.open("res://Data/SaveData.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func update_score(level_id: String, gifts_lost: int, time: float):
	var data = load_save()
	var lvl = data.levels.get(level_id, {"fewest": INF, "bestTime": INF})

	var better = false
	
# if fewer gifts missed, or same gifts but faster time
	if gifts_lost < lvl.fewest:
		lvl.fewest = gifts_lost
		lvl.bestTime = round(time * 10) / 10.0   # round to 1 decimal
		better = true
	# OR same gifts lost but faster time
	elif gifts_lost == lvl.fewest and time < lvl.bestTime:
		lvl.bestTime = round(time * 10) / 10.0
		better = true

	if better:
		data.levels[level_id] = lvl
		save_data(data)

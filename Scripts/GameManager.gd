extends Node

#@onready var level_container = $LevelContainer
@export var level_container: Node2D

var current_level: Node = null
var currentLevelResource: levelResource

var current_housesFilled: int = 0 

func _on_house_filled():
	current_housesFilled += 1
	
	# check if finished
	current_level = level_container.get_child(0)
	currentLevelResource = current_level.level_data	
	if current_housesFilled >= currentLevelResource.numberOfHouses:
		_on_level_finish()
		
	else:
		pass#print("current_housesFilled: " + str(current_housesFilled))

func _on_level_finish():
	await get_tree().create_timer(0.4).timeout
	
# evaluate and save score TODO:(show score screen really...)
	
# return level select menu
	$LevelSelect.show() 

# remove level
	current_level = level_container.get_child(0)
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
	
	currentLevelResource = inst.level_data

# connect all houses in this level
	for House in get_tree().get_nodes_in_group("house"):
		if inst.is_ancestor_of(House):  # only houses in this level
			House._on_house_filled.connect(_on_house_filled)

func _getLevelPath(level_num: int) -> String:
		var level_num_str: String = str(level_num)
		if level_num_str.length()==1:
			level_num_str = "0"+level_num_str
		return "res://Levels/Level_" + level_num_str + ".tscn"

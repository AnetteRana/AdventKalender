extends Node

var filePath: String = "res://Data/SaveData.json"
var save_data_cache: Dictionary = {} 

func _ready() -> void:
	save_data_cache = get_saved_dictionary()

func get_saved_dictionary() -> Dictionary:
	var file = FileAccess.open(filePath, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var parsed = JSON.parse_string(text)

		if typeof(parsed) == TYPE_DICTIONARY:
			return parsed
		else: # else if file exists but broken:
			return {"levels": {}}
	else: # else if no file found:
		return {"levels": {}}

func save_data(): # overwrite existing save with input
	var file = FileAccess.open(filePath, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data_cache))

# GameManager->_on_level_finish()   every time level end
func update_score(level_id: String, gifts_lost: int, time: float):
	#var data: Dictionary = save_data_cache
	var current_lvl_savedata = save_data_cache.levels.get(level_id, {"wastedGifts": INF, "bestTime": INF})

	var isNewRecord = false #assume no new record
	
# if fewer gifts missed, or same gifts but faster time = overrite old save for level
	if gifts_lost < current_lvl_savedata.wastedGifts:
		current_lvl_savedata.wastedGifts = gifts_lost
		current_lvl_savedata.bestTime = round(time * 10) / 10.0   # round to 1 decimal
		isNewRecord = true
# OR same gifts lost but faster time
	elif gifts_lost == current_lvl_savedata.wastedGifts and time < current_lvl_savedata.bestTime:
		current_lvl_savedata.bestTime = round(time * 10) / 10.0
		isNewRecord = true

	if isNewRecord:
		save_data_cache.levels[level_id] = current_lvl_savedata
		save_data()

# getters for UI
func get_level_wastedGifts(level_id: String) -> String:
	var current_lvl_savedata = save_data_cache.levels.get(level_id, {"wastedGifts": INF, "bestTime": INF})
	return str(current_lvl_savedata.wastedGifts)
func get_level_bestTime(level_id: String) -> String:
	var current_lvl_savedata = save_data_cache.levels.get(level_id, {"wastedGifts": INF, "bestTime": INF})
	return str(current_lvl_savedata.bestTime)

extends Node2D

@export var Level_ID: String
@export var HousesInLevel: int

func _setHouseNumber():
	HousesInLevel = get_tree().get_nodes_in_group("house").size()
	GameManager.currentHousesInLevel = HousesInLevel

func _ready() -> void:
	
	_setHouseNumber()
	
	GameManager.currentLevelID = Level_ID
	
	

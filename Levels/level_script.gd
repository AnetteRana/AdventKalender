extends Node2D

@export var Level_ID: String
@export var HousesInLevel: int

func _ready() -> void:
	GameManager.currentLevelID = Level_ID
	GameManager.currentHousesInLevel = HousesInLevel

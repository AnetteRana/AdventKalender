extends Node2D

@export var numberOfReindeerPairs: int = 1
@export var speedOverrite: float = 150.0
var allReindeer: Array[Node2D] = []

func _ready() -> void:
	_create_extra_reindeer()
		
func _create_extra_reindeer() -> void:
	for i in range(numberOfReindeerPairs): #0, 1... make reindeer
		print(i)
		var reindeerChild = preload("res://Scenes/PlayerCharacter_folder/Reindeer.tscn").instantiate()
		add_child(reindeerChild)
		allReindeer.append(reindeerChild)
		var movementComponent = reindeerChild.get_node("movementComp")
		
		if i == 0: #if first
			$Sleigh/movementComp.follow_target = reindeerChild #link sleigh
		else:
			var previousDeerMovementComp = allReindeer[i-1].get_node("movementComp")
			previousDeerMovementComp.follow_target = reindeerChild

		if i >= numberOfReindeerPairs-1: #if last
			movementComponent.is_leader = true
			movementComponent.forward_speed = speedOverrite
			
	_createReins()
			
func _createReins() -> void:
	$Sleigh/movementComp.spawn_reins()
	for each in allReindeer:
		var moveComp = each.get_node("movementComp")
		moveComp.spawn_reins()
		

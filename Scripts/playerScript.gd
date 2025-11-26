extends Node2D

@export var gift_scene: PackedScene

func _physics_process(delta: float):
	if Input.is_action_just_pressed("DropGift"):
		spawn_gift()
		
func spawn_gift():
	if gift_scene == null:
		return
		
	var gift = gift_scene.instantiate()
	gift.position = position
	get_parent().add_child(gift)

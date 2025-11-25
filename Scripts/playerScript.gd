extends Node2D

@export var forward_speed: float = 150
@export var rotation_speed: float = 2.0

func _physics_process(delta: float):
	var turn = 0.0
	if Input.is_action_pressed("Rotate_anticlockwise"):
		turn-=1.0
	if Input.is_action_pressed("Rotate_clockwise"):
		turn += 1.0
		
	rotation += turn * rotation_speed * delta
	position += Vector2.RIGHT.rotated(rotation) * forward_speed * delta

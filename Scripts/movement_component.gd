extends Node

@export var is_leader: bool = false
@export var follow_target: Node2D
@export var follow_distance: float = 30.0

@export var forward_speed: float = 150
@export var rotation_speed: float = 2.0

func _physics_process(delta: float) -> void:
	var body:= get_parent() as Node2D
	if body == null:
		return
		
	if is_leader:
		_leader_move(body, delta)
	else:
		_follower_move(body, delta)
		
func _leader_move(body: Node2D, delta: float) -> void:
	var turn := 0.0
	if Input.is_action_pressed("Rotate_anticlockwise"):
		turn-=1.0
	if Input.is_action_pressed("Rotate_clockwise"):
		turn += 1.0
		
	body.rotation += turn * rotation_speed * delta
	body.position += Vector2.RIGHT.rotated(body.rotation) * forward_speed * delta
	
func _follower_move(body: Node2D, delta: float) -> void:
	if follow_target == null:
		return
		
	var desired_pos = follow_target.position - follow_target.transform.x * follow_distance
	body.position = body.position.lerp(desired_pos, 8.0 * delta)
	var desired_rot = (follow_target.position - body.position).angle()
	body.rotation = lerp_angle(body.rotation, desired_rot, 8.0 * delta)

extends Node

@export var is_leader: bool = false
@export var follow_target: Node2D
@export var follow_distance: float = 30.0

@export var forward_speed: float = 150
@export var rotation_speed: float = 2.0

@export var bounce_padding: float = 5.0
@export var bounce_damp: float = 1.0

func _physics_process(delta: float) -> void:
	var body:= get_parent() as Node2D
	if body == null:
		return
		
	# movement
	if is_leader:
		_leader_move(body, delta)
	else:
		_follower_move(body, delta)
		
	_bounce_edges(body)
		
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

func _bounce_edges(body: Node2D) -> void:
	var screen_size = get_viewport().get_visible_rect().size

	var hit_vertical := false   # left/right walls
	var hit_horizontal := false # top/bottom walls

	# X bounds
	if body.position.x < bounce_padding:
		body.position.x = bounce_padding
		hit_vertical = true
	elif body.position.x > screen_size.x - bounce_padding:
		body.position.x = screen_size.x - bounce_padding
		hit_vertical = true

	# Y bounds
	if body.position.y < bounce_padding:
		body.position.y = bounce_padding
		hit_horizontal = true
	elif body.position.y > screen_size.y - bounce_padding:
		body.position.y = screen_size.y - bounce_padding
		hit_horizontal = true

	if not (hit_vertical or hit_horizontal):
		return

	var forward = Vector2.RIGHT.rotated(body.rotation)
	var reflected = forward

	if hit_vertical:
		reflected.x = -reflected.x
	if hit_horizontal:
		reflected.y = -reflected.y

	var target_angle = reflected.angle()
	body.rotation = lerp_angle(body.rotation, target_angle, bounce_damp)

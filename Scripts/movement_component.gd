extends Node

@export var is_leader: bool = false
@export var follow_target: Node2D
@export var follow_distance: float = 30.0

@export var forward_speed: float = 150
@export var rotation_speed: float = 2.0

@export var bounce_padding: float = 5.0
@export var bounce_damp: float = 1.0

#@export var rein_line_scene: PackedScene
const REIN_LINE_SCENE := preload("res://Scenes/PlayerCharacter_folder/ReinLine2D.tscn")
		
func spawn_reins()->void:			
	if not follow_target:
		return
	
	var my_parent:= get_parent() as Node2D
	
	### Right side ###
# find anchors
	var self_anchor_R: Node2D = my_parent.find_child("LineAnchor_R", true, false)
	var target_anchor_R: Node2D = follow_target.find_child("LineAnchor_R", true, false)
	
	if not (self_anchor_R and target_anchor_R):
		return
# make lines
	var line_R = REIN_LINE_SCENE.instantiate()
#give node2d to/from
	line_R.from_anchor = self_anchor_R
	line_R.to_anchor = target_anchor_R
# attach to root
	my_parent.add_child.call_deferred(line_R)
### Left side ###
# find anchors
	var self_anchor_L: Node2D = my_parent.find_child("LineAnchor_L", true, false)
	var target_anchor_L: Node2D = follow_target.find_child("LineAnchor_L", true, false)
	
	if not (self_anchor_L and target_anchor_L):
		return
# make lines
	var line_L = REIN_LINE_SCENE.instantiate()
#give node2d to/from
	line_L.from_anchor = self_anchor_L
	line_L.to_anchor = target_anchor_L
# attach to root
	my_parent.add_child.call_deferred(line_L)

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
	
	var globalPos:= body.global_position
	
	# X bounds
	if globalPos.x < bounce_padding:
		globalPos.x = bounce_padding
		hit_vertical = true
	elif globalPos.x > screen_size.x - bounce_padding:
		globalPos.x = screen_size.x - bounce_padding
		hit_vertical = true

	# Y bounds
	if globalPos.y < bounce_padding:
		globalPos.y = bounce_padding
		hit_horizontal = true
	elif globalPos.y > screen_size.y - bounce_padding:
		globalPos.y = screen_size.y - bounce_padding
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
	
	body.global_position = globalPos
	body.global_rotation = lerp_angle(body.global_rotation, target_angle, bounce_damp)

# Main.gd — attach to a Node2D
extends Node2D

# --- Constants ---
const HOUSE_COUNT := 30
const HOUSE_R := 14.0
const REINDEER_R := 10.0
const SLED_R := 12.0

const REINDEER_SPEED := 180.0    # px/s forward
const TURN_RATE := 2.6           # rad/s

const LEASH_LEN := 48.0          # desired distance sledge stays behind
const FOLLOW_STRENGTH := 6.0     # how quickly the sledge corrects toward target

const GIFT_START := 10.0
const GIFT_SHRINK := 18.0
const MIN_HOUSE_DIST := 60.0
const MARGIN := 30.0

const BG_COLOR := Color(0.92, 0.95, 1.0) # bluish white

# --- State ---
var viewport_size: Vector2

var reindeer_pos := Vector2.ZERO
var reindeer_angle := 0.0

var sled_pos := Vector2.ZERO
var sled_angle := 0.0

var drops_left := HOUSE_COUNT
var game_over := false

var houses: Array[Dictionary] = []   # {"pos": Vector2, "delivered": bool}
var gifts:  Array[Dictionary] = []   # {"pos": Vector2, "size": float, "alive": bool}

func _ready() -> void:
	viewport_size = get_viewport_rect().size
	_reset_game()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_drop_gift()
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		_reset_game()

func _process(delta: float) -> void:
	if game_over:
		queue_redraw()
		return

	_handle_input(delta)
	_move_reindeer(delta)
	_move_sled(delta)
	_update_gifts(delta)

	if drops_left == 0 and gifts.is_empty():
		game_over = true

	queue_redraw()

# --- Input / Movement ---
func _handle_input(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		reindeer_angle -= TURN_RATE * delta
	if Input.is_action_pressed("ui_right"):
		reindeer_angle += TURN_RATE * delta

func _move_reindeer(delta: float) -> void:
	var dir := Vector2.RIGHT.rotated(reindeer_angle)
	reindeer_pos += dir * REINDEER_SPEED * delta

	var bounced := false
	if reindeer_pos.x < REINDEER_R:
		reindeer_pos.x = REINDEER_R
		reindeer_angle = PI - reindeer_angle
		bounced = true
	elif reindeer_pos.x > viewport_size.x - REINDEER_R:
		reindeer_pos.x = viewport_size.x - REINDEER_R
		reindeer_angle = PI - reindeer_angle
		bounced = true
	if reindeer_pos.y < REINDEER_R:
		reindeer_pos.y = REINDEER_R
		reindeer_angle = -reindeer_angle
		bounced = true
	elif reindeer_pos.y > viewport_size.y - REINDEER_R:
		reindeer_pos.y = viewport_size.y - REINDEER_R
		reindeer_angle = -reindeer_angle
		bounced = true

	if bounced:
		while reindeer_angle < -PI: reindeer_angle += TAU
		while reindeer_angle >  PI: reindeer_angle -= TAU

func _move_sled(delta: float) -> void:
	# Desired sled spot: behind the reindeer along its facing
	var behind_dir := Vector2.RIGHT.rotated(reindeer_angle)
	var target := reindeer_pos - behind_dir * LEASH_LEN

	# Spring toward target
	var to_target := target - sled_pos
	sled_pos += to_target * FOLLOW_STRENGTH * delta

	# Face movement direction (nice visual)
	if to_target.length() > 0.001:
		sled_angle = to_target.angle()

	# Clamp inside bounds
	if sled_pos.x < SLED_R: sled_pos.x = SLED_R
	if sled_pos.x > viewport_size.x - SLED_R: sled_pos.x = viewport_size.x - SLED_R
	if sled_pos.y < SLED_R: sled_pos.y = SLED_R
	if sled_pos.y > viewport_size.y - SLED_R: sled_pos.y = viewport_size.y - SLED_R

func _drop_gift() -> void:
	if drops_left <= 0 or game_over:
		return
	drops_left -= 1
	gifts.append({"pos": sled_pos, "size": GIFT_START, "alive": true})

func _update_gifts(delta: float) -> void:
	for g in gifts:
		if not g.alive:
			continue
		g.size -= GIFT_SHRINK * delta
		if g.size <= 0.0:
			g.alive = false
			continue
		for h in houses:
			if h.delivered:
				continue
			if g.pos.distance_squared_to(h.pos) <= pow(HOUSE_R + max(2.0, g.size), 2):
				h.delivered = true
				g.alive = false
				break
	gifts = gifts.filter(func(it): return it.alive)

# --- Setup ---
func _reset_game() -> void:
	game_over = false
	drops_left = HOUSE_COUNT
	reindeer_pos = viewport_size * 0.5 + Vector2(0, -20)
	reindeer_angle = 0.0
	sled_pos = reindeer_pos - Vector2(LEASH_LEN, 0)
	sled_angle = 0.0
	gifts.clear()
	_spawn_houses()

func _spawn_houses() -> void:
	houses.clear()
	var tries := 0
	while houses.size() < HOUSE_COUNT and tries < 1000:
		tries += 1
		var p := Vector2(
			randf_range(MARGIN, viewport_size.x - MARGIN),
			randf_range(MARGIN, viewport_size.y - MARGIN)
		)
		var ok := true
		for h in houses:
			if p.distance_to(h.pos) < MIN_HOUSE_DIST:
				ok = false
				break
		if ok:
			houses.append({"pos": p, "delivered": false})

# --- Draw ---
func _draw() -> void:
	# Background
	draw_rect(Rect2(Vector2.ZERO, viewport_size), BG_COLOR, true)

	# Houses
	for h in houses:
		var col: Color = Color(1.0, 0.5, 0.5) if h.delivered else Color(0.9, 0.2, 0.2)
		var p: Vector2 = h.pos
		draw_rect(Rect2(p - Vector2(HOUSE_R, HOUSE_R), Vector2(HOUSE_R * 2.0, HOUSE_R * 2.0)), col, true)
		draw_rect(Rect2(p + Vector2(-3, 2), Vector2(6, 8)), Color(0.1, 0.1, 0.1), true)
		draw_line(p + Vector2(-HOUSE_R - 2, -HOUSE_R + 2), p + Vector2(0, -HOUSE_R - 8), Color.BLACK, 2.0)
		draw_line(p + Vector2(HOUSE_R + 2, -HOUSE_R + 2),  p + Vector2(0, -HOUSE_R - 8), Color.BLACK, 2.0)

	# Gifts
	for g in gifts:
		var s: float = max(2.0, g.size)
		var gp: Vector2 = g.pos
		draw_rect(Rect2(gp - Vector2(s, s), Vector2(2.0 * s, 2.0 * s)), Color(1.0, 0.1, 0.1), true)
		draw_line(gp + Vector2(0, -s), gp + Vector2(0, s), Color.BLACK, 1.0)
		draw_line(gp + Vector2(-s, 0), gp + Vector2(s, 0), Color.BLACK, 1.0)

	# Reindeer (triangle body + antlers)
	var rxf := Transform2D(reindeer_angle, reindeer_pos)
	_draw_rotated_poly(rxf, [Vector2(12,0), Vector2(-10,-8), Vector2(-10,8)], Color(0.6,0.4,0.2))
	draw_line(rxf * Vector2(-6,-6), rxf * Vector2(-12,-12), Color(0.3,0.2,0.1), 2.0)
	draw_line(rxf * Vector2(-6, 6), rxf * Vector2(-12, 12), Color(0.3,0.2,0.1), 2.0)

	# Rope
	draw_line(reindeer_pos, sled_pos, Color(0.2, 0.2, 0.2, 0.6), 1.5)

	# Sledge
	var sxf := Transform2D(sled_angle, sled_pos)
	_draw_rotated_rect(sxf, Vector2(-14, -8), Vector2(28, 16), Color(0.55, 0.35, 0.2))
	draw_line(sxf * Vector2(-12, 10), sxf * Vector2(12, 10), Color(0.1, 0.1, 0.1), 2.0)
	draw_line(sxf * Vector2(-12, 12), sxf * Vector2(12, 12), Color(0.1, 0.1, 0.1), 2.0)
	draw_circle(sxf * Vector2(10, -10), 3.0, Color(0.9, 0.2, 0.2))

func _draw_rotated_rect(xf: Transform2D, top_left: Vector2, size: Vector2, col: Color) -> void:
	var a := xf * top_left
	var b := xf * (top_left + Vector2(size.x, 0))
	var c := xf * (top_left + size)
	var d := xf * (top_left + Vector2(0, size.y))
	draw_colored_polygon(PackedVector2Array([a, b, c, d]), col)

func _draw_rotated_poly(xf: Transform2D, pts: Array, col: Color) -> void:
	var arr := PackedVector2Array()
	for p in pts: arr.push_back(xf * p)
	draw_colored_polygon(arr, col)

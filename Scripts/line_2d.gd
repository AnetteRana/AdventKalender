extends Line2D

@export var from_anchor: Node2D
@export var to_anchor: Node2D

func _process(_delta: float) -> void:
	if from_anchor and to_anchor:
		points=[
			to_local(from_anchor.global_position),
			to_local(to_anchor.global_position)
			]

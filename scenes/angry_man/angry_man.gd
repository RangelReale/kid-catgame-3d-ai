extends Area3D

## Emitted once, when the man catches the cat.
signal caught

## Walking speed, in units per second. Slower than the cat, so it can run away.
@export var speed: float = 2.5
## Seconds the man waits before he starts walking after the cat.
@export var start_delay: float = 1.5

var _player: Node3D
var _caught: bool = false

@onready var _visual: Node3D = $Visual


func _ready() -> void:
	add_to_group("catcher")
	body_entered.connect(_on_body_entered)


## The man walks straight along x toward the cat. Walls and desks do not stop
## him.
func _physics_process(delta: float) -> void:
	if start_delay > 0.0:
		start_delay -= delta
		return
	if _caught:
		return
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")
		if _player == null:
			return
	var direction := signf(_player.global_position.x - global_position.x)
	position.x += speed * direction * delta
	if direction != 0.0:
		_visual.scale.x = direction


func _on_body_entered(body: Node3D) -> void:
	if body is Player and not _caught:
		_caught = true
		caught.emit()

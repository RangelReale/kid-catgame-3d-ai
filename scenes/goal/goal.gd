extends Area3D

## Emitted once, when the cat touches the flag.
signal reached

## When true, the flag stays hidden until something calls unlock().
@export var locked: bool = false


func _ready() -> void:
	add_to_group("goal")
	body_entered.connect(_on_body_entered)
	if locked:
		hide()
		monitoring = false


## Shows the flag and lets the cat touch it.
func unlock() -> void:
	show()
	set_deferred("monitoring", true)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		set_deferred("monitoring", false)
		reached.emit()

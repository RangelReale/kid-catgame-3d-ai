extends Area3D

## Emitted once, when the cat bumps into the suitcase and makes a mess.
signal caught

var _caught: bool = false


func _ready() -> void:
	add_to_group("catcher")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Player and not _caught:
		_caught = true
		caught.emit()

@tool
extends Node3D

## The light and the background of a level: a sun light with shadows and a
## plain sky colour. Underwater levels turn on the fog.

@export var sky_color: Color = Color(0.53, 0.81, 0.92):
	set(value):
		sky_color = value
		_update()
@export var ambient_color: Color = Color(0.85, 0.9, 1.0):
	set(value):
		ambient_color = value
		_update()
## Turn off on slow devices to draw faster.
@export var shadows: bool = true:
	set(value):
		shadows = value
		_update()
@export var fog: bool = false:
	set(value):
		fog = value
		_update()
@export var fog_density: float = 0.02:
	set(value):
		fog_density = value
		_update()

var _world_environment := WorldEnvironment.new()
var _light := DirectionalLight3D.new()


func _init() -> void:
	add_child(_world_environment, false, INTERNAL_MODE_FRONT)
	add_child(_light, false, INTERNAL_MODE_FRONT)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_energy = 0.45
	_world_environment.environment = environment
	# The light comes from the top left, a little in front.
	_light.rotation_degrees = Vector3(-55, -35, 0)
	_light.light_energy = 0.15
	_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	_light.directional_shadow_max_distance = 40.0
	_light.shadow_blur = 1.5
	_update()


func _update() -> void:
	var environment := _world_environment.environment
	environment.background_color = sky_color
	environment.ambient_light_color = ambient_color
	environment.fog_enabled = fog
	environment.fog_light_color = sky_color
	environment.fog_density = fog_density
	_light.shadow_enabled = shadows

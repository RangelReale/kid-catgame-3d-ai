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

## In the headset the real room shows behind the level, so the background
## becomes this colour instead of the sky: fully transparent in the headset,
## or a plain room grey on a computer screen. The diorama rig sets both.
var passthrough: bool = false:
	set(value):
		passthrough = value
		_update()
var passthrough_color: Color = Color(0, 0, 0, 0):
	set(value):
		passthrough_color = value
		_update()

## Paints the whole level in shades of brown, like an old photo. The headset
## uses it behind the title and the credits, where the flat sepia layer of
## the screen does not show.
var sepia: bool = false:
	set(value):
		sepia = value
		_update()
## The brown that the brightest parts turn into, like the screen's sepia.
var sepia_tint: Color = Color(1.0, 0.86, 0.62)

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
	# Grey first, then each grey becomes a brown from black to the tint.
	environment.adjustment_saturation = 0.0
	environment.adjustment_brightness = 1.2
	var gradient := Gradient.new()
	gradient.set_color(0, Color.BLACK)
	gradient.set_color(1, sepia_tint)
	var ramp := GradientTexture1D.new()
	ramp.gradient = gradient
	environment.adjustment_color_correction = ramp
	# The light comes from the top left, a little in front.
	_light.rotation_degrees = Vector3(-55, -35, 0)
	_light.light_energy = 0.15
	_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	_light.directional_shadow_max_distance = 40.0
	_light.shadow_blur = 1.5
	_update()


func _update() -> void:
	var environment := _world_environment.environment
	environment.background_color = passthrough_color if passthrough else sky_color
	environment.ambient_light_color = ambient_color
	environment.fog_enabled = fog
	environment.fog_light_color = sky_color
	environment.fog_density = fog_density
	environment.adjustment_enabled = sepia
	_light.shadow_enabled = shadows

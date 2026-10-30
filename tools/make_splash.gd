extends SceneTree

## Draws the opening picture from the real cat, sharp and with the sky colour
## around it, so it blends with the background the engine paints:
##   godot_console --path . -s tools/make_splash.gd

const OUTPUT := "res://assets/icons/splash.png"
## Side of the square picture, in pixels.
const PICTURE_SIZE := 2048
## Height of the view, in game units. Smaller makes the cat bigger.
const VIEW_SIZE := 1.5
## The middle of the cat.
const TARGET := Vector3(-0.08, 0.32, 0)
const CAMERA_POSITION := Vector3(-0.5, 0.75, 4)


func _initialize() -> void:
	_draw_picture.call_deferred()


func _draw_picture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(PICTURE_SIZE, PICTURE_SIZE)
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_8X
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	var cat: Node3D = load("res://scenes/player/player.tscn").instantiate()
	cat.process_mode = Node.PROCESS_MODE_DISABLED
	viewport.add_child(cat)

	var environment := Environment.new()
	environment.background_mode = Environment.BG_CLEAR_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color.WHITE
	environment.ambient_light_energy = 0.6
	var world := WorldEnvironment.new()
	world.environment = environment
	viewport.add_child(world)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	viewport.add_child(light)

	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = VIEW_SIZE
	viewport.add_child(camera)
	camera.look_at_from_position(CAMERA_POSITION, TARGET)

	for i in 3:
		await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png(OUTPUT)
	quit()

extends Spatial

func _ready():
	# var normalCamera = get_node("NormalPassViewport/Camera")
	pass

func saveScreenshot(viewport: Viewport, path: String):
	# var img = viewport.get_texture().get_data()
	var img = VisualServer.texture_get_data(VisualServer.viewport_get_texture(viewport.get_viewport_rid()))
	img.flip_y()
	img.save_png(path)

func copyViewportState(fromViewport: Viewport, toViewport: Viewport):
	var toRID = toViewport.get_viewport_rid()
	var camera = fromViewport.get_camera()
	VisualServer.viewport_attach_camera( toRID, camera.get_camera_rid() )
	var size = fromViewport.get_viewport().size
	VisualServer.viewport_set_size(toRID, size.x, size.y)

# Called when the node enters the scene tree for the first time.
func _input(_ev):
	if Input.is_key_pressed(KEY_K):

		var viewport = get_viewport()
		var viewportRID = viewport.get_viewport_rid()
		# saveScreenshot(viewport, "./screenshot.png")

		var normalViewport = get_node("NormalPassViewport")
		var normalViewportRID = normalViewport.get_viewport_rid()

		copyViewportState(viewport, normalViewport)

		VisualServer.viewport_set_active(viewportRID, false)
		VisualServer.viewport_set_update_mode(normalViewportRID, VisualServer.VIEWPORT_UPDATE_ALWAYS)

		VisualServer.force_draw()

		VisualServer.viewport_set_active(viewportRID, true)
		VisualServer.viewport_set_update_mode(normalViewportRID, VisualServer.VIEWPORT_UPDATE_DISABLED)

		saveScreenshot(normalViewport, "./normalPass.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

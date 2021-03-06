extends Spatial

const normal_pass_mesh_instances = "normal_pass_mesh_instances"

var normalMaterial: Material
var emptyEnvironment: Environment
func _ready():
	normalMaterial = load("res://assets/normal_material.tres")
	emptyEnvironment = load("res://assets/empty_environment.tres")

	VisualServer.connect("frame_pre_draw", self, "on_before_render")

func saveScreenshot(viewport: Viewport, path: String):
	var img = VisualServer.texture_get_data(VisualServer.viewport_get_texture(viewport.get_viewport_rid()))
	img.flip_y()
	img.save_png(path)

func copyViewportState(fromViewport: Viewport, toViewport: Viewport):
	var toRID = toViewport.get_viewport_rid()
	var camera = fromViewport.get_camera()
	VisualServer.viewport_attach_camera( toRID, camera.get_camera_rid() )
	var size = fromViewport.get_viewport().size
	VisualServer.viewport_set_size(toRID, size.x, size.y)

func setOverrideMaterials(nodes: Array, material: Material):
	for node in nodes:
		if node is MeshInstance:
			node.material_override = material
			# print(node.name)

func getGroupNodes(group: String):
	return get_tree().get_nodes_in_group(group)

func renderBuffers():
	var viewport = get_viewport()
	var viewportRID = viewport.get_viewport_rid()
	var camera = viewport.get_camera()
	var cameraRID = camera.get_camera_rid()
	var environment = camera.environment
	var environmentRID = environment.get_rid()
	
	var normalViewport = get_node("NormalPassViewport")
	var normalViewportRID = normalViewport.get_viewport_rid()
	copyViewportState(viewport, normalViewport)
	
	VisualServer.viewport_set_active(viewportRID, false)
	VisualServer.viewport_set_update_mode(normalViewportRID, VisualServer.VIEWPORT_UPDATE_ALWAYS)
	setOverrideMaterials( getGroupNodes(normal_pass_mesh_instances), normalMaterial)
	VisualServer.camera_set_environment(cameraRID, emptyEnvironment.get_rid())

	VisualServer.force_draw(false, 0.0)

	VisualServer.viewport_set_active(viewportRID, true)
	VisualServer.viewport_set_update_mode(normalViewportRID, VisualServer.VIEWPORT_UPDATE_DISABLED)
	setOverrideMaterials( getGroupNodes(normal_pass_mesh_instances), null)
	VisualServer.camera_set_environment(cameraRID, environmentRID)

# Called when the node enters the scene tree for the first time.
func _input(_ev):
	if Input.is_key_pressed(KEY_K):
		renderBuffers()
		saveScreenshot(get_node("NormalPassViewport"), "./normalPass.png")

var renderDepth = 0
func on_before_render():
	# VisualServer.force_draw triggers the frame_pre_draw signal, so we have to track the call depth.
	if renderDepth == 0:
		renderDepth += 1
		renderBuffers()
		renderDepth -= 1

		# for node in getGroupNodes(normal_pass_mesh_instances):
		# 	node.
	
	# var frame = Engine.get_frames_drawn()
	# if frame % 10 == 0:
	# 	print(Engine.get_frames_per_second())

extends Spatial

# enum our buttons, should find a way to put this more central
enum Buttons {
	VR_BUTTON_BY = 1,
	VR_GRIP = 2,
	VR_BUTTON_3 = 3,
	VR_BUTTON_4 = 4,
	VR_BUTTON_5 = 5,
	VR_BUTTON_6 = 6,
	VR_BUTTON_AX = 7,
	VR_BUTTON_8 = 8,
	VR_BUTTON_9 = 9,
	VR_BUTTON_10 = 10,
	VR_BUTTON_11 = 11,
	VR_BUTTON_12 = 12,
	VR_BUTTON_13 = 13,
	VR_PAD = 14,
	VR_TRIGGER = 15
}

## Button to place camera
export (Buttons) var place_button_id = Buttons.VR_TRIGGER

## Camera target
export (NodePath) var target = null

## Camera target offset
export (Vector3) var offset = Vector3.ZERO

# Node references
onready var _screen: Sprite3D = $Sprite3D
onready var _camera: Camera = $Sprite3D/Viewport/Camera
onready var _controller: ARVRController = get_parent()
onready var _target: Spatial = get_node(target)

func _process(delta):
	# Handle placing the camera
	if _controller.get_is_active() and _controller.is_button_pressed(place_button_id):
		_camera.global_transform = _controller.global_transform
		_screen.visible = true

	# Have the camera face the target
	var target = _target.global_transform.origin + offset
	_camera.global_transform = _camera.global_transform.looking_at(target, Vector3.UP)

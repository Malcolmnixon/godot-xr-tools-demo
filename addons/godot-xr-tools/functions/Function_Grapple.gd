tool
class_name Function_Grapple
extends MovementProvider


##
## Movement Provider for Grapple Movement
##
## @desc:
##     This script provide simple grapple based movement - "bat hook" style where the player moves 
##     directly to the grapple location. This script works with the PlayerBody attached to the
##     players ARVROrigin.
##
##     The player may have multiple movement nodes attached to different
##     controllers to provide different types of movement.
##
##     The player can have a grapple node attached to each hand and the movement should not break.
##


## Signal emitted when grapple starts
signal grapple_started()

## Signal emitted when grapple finishes
signal grapple_finished()


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


## Movement provider order
export var order := 20

## Grapple speed - use to adjust how far player can go with grapple.  Lower setting will mean player may not reach targeted point.
## Higher speed may eventually make it hard for the player to stay in the world or on surfaces due to too much velocity.
export var grapple_speed := 1.5

##Grapple length - use to adjust maximum distance for possible grapple hooking.
export var grapple_length := 15.0

##Probably need to add export variables for line size, maybe line material at some point so dev does not need to make children editable to do this
##For now, right click on grapple node and make children editable to edit these facets.
export var rope_width := 0.02

## Grapple button (triggers grappling movement).  Be sure this button does not conflict with other functions.
export (Buttons) var grapple_button_id = Buttons.VR_TRIGGER


# Hook related variables
var hook_point = Vector3(0,0,0)

# Grapple button state
var _grapple_button := false

# Perform grapple-push (to target)
var _grapple_push := false

# Get line creation nodes
onready var line_helper = $LineHelper
onready var line = $LineHelper/Line

# Get Controller node - consider way to universalize this if user wanted to attach this
# to a gun instead of player's hand.  Could consider variable to select controller instead.
onready var _controller : ARVRController = get_parent()

# Get Raycast node
onready var grapple_raycast : RayCast = $Grapple_RayCast

# Get Grapple Target Node 
onready var grapple_target = $Grapple_Target


# Function run when node is added to scene
func _ready():
	# Ensure grapple length is valid
	var min_hook_length = 1.5 * ARVRServer.world_scale
	if grapple_length < min_hook_length:
		grapple_length = min_hook_length

	# Set ray-cast
	grapple_raycast.cast_to = Vector3(0, 0, -grapple_length) * ARVRServer.world_scale #Is WS necessary here?
	
	# Deal with line
	line.radius = rope_width
	line.hide()


# Called before every frame update
func _process(delta: float):
	# Skip if disabled or the controller isn't active
	if !enabled or !_controller or !_controller.get_is_active():
		set_grappling(false)
		return

	# Update grapple button state
	var old_grapple_button = _grapple_button
	_grapple_button = _controller.is_button_pressed(grapple_button_id)

	# Handle grapple transitions
	if is_active:
		# Handle release of grapple
		if !_grapple_button:
			set_grappling(false)
			return

		# Update grapple line
		var line_length = (hook_point - _controller.global_transform.origin).length()
		line_helper.look_at(hook_point, Vector3.UP)
		line.height = line_length
		line.translation.z = line_length / -2
		line.visible = true
	elif grapple_raycast.is_colliding():
		# Handle firing grapple:
		if _grapple_button and !old_grapple_button:
			hook_point = grapple_raycast.get_collision_point()
			_grapple_push = true
			set_grappling(true)
			return

		# Update visible grapple target
		grapple_target.global_transform.origin  = grapple_raycast.get_collision_point()
		grapple_target.global_transform = grapple_target.global_transform.orthonormalized()
		grapple_target.visible = true
	else:
		# Hide grapple target
		grapple_target.visible = false


# Perform grapple movement
func physics_movement(delta: float, player_body: PlayerBody):
	# Skip if not flying
	if !is_active:
		return

	# Get hook direction
	var hook_direction = (hook_point - _controller.global_transform.origin).normalized()
	
	# Apply standard gravity 
	player_body.velocity += Vector3.UP * player_body.gravity * delta

	# Cancel any movement away from hook_point
	var vdot = player_body.velocity.dot(hook_direction)
	if vdot < 0.0:
		player_body.velocity -= hook_direction * vdot

	# Perform grapple physics
	if _grapple_push:
		# Apply initial impulse towards grapple
		_grapple_push = false
		player_body.velocity += hook_direction * grapple_speed

	# Perform exclusive movement as we have dealt with gravity
	player_body.velocity = player_body.move_and_slide(player_body.velocity)
	return true


func set_grappling(active: bool) -> void:
	# Skip if no change
	if active == is_active:
		return

	# Update state
	is_active = active

	# Handle state change
	if is_active:
		emit_signal("grapple_started")
	else:
		# Disable visible artifacts - may be enabled later
		line.visible = false
		grapple_target.visible = false

		# Report 
		emit_signal("grapple_finished")


# This method verifies the MovementProvider has a valid configuration.
func _get_configuration_warning():
	# Check the controller node
	var test_controller = get_parent()
	if !test_controller or !test_controller is ARVRController:
		return "Unable to find ARVR Controller node"

	# Call base class
	return ._get_configuration_warning()

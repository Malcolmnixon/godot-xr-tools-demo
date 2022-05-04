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

# Grapple state
enum GrappleState {
	IDLE,			# Idle
	TARGET,			# Grapple has target
	FIRED,			# Grapple is fired
	WINCHING,		# Grapple is winching
}


## Movement provider order
export var order := 20

## Grapple length - use to adjust maximum distance for possible grapple hooking.
export var grapple_length := 15.0

## Grapple collision mask
export (int, LAYERS_3D_PHYSICS) var grapple_collision_mask = 1 setget _set_grapple_collision_mask

## Impulse speed applied to the player on first grapple
export var impulse_speed := 10.0

## Winch speed applied to the player while the grapple is held
export var winch_speed := 2.0

##Probably need to add export variables for line size, maybe line material at some point so dev does not need to make children editable to do this
##For now, right click on grapple node and make children editable to edit these facets.
export var rope_width := 0.02

## Air friction while grappling
export var friction := 0.1

## Grapple button (triggers grappling movement).  Be sure this button does not conflict with other functions.
export (Buttons) var grapple_button_id : int = Buttons.VR_TRIGGER

# Grapple state
var grapple_state : int = GrappleState.IDLE

# Hook related variables
var hook_point := Vector3(0,0,0)

# Grapple button state
var _grapple_button := false

# Get line creation nodes
onready var _line_helper : Spatial = $LineHelper
onready var _line : CSGCylinder = $LineHelper/Line

# Get Controller node - consider way to universalize this if user wanted to attach this
# to a gun instead of player's hand.  Could consider variable to select controller instead.
onready var _controller : ARVRController = get_parent()

# Get Raycast node
onready var _grapple_raycast : RayCast = $Grapple_RayCast

# Get Grapple Target Node 
onready var _grapple_target : Spatial = $Grapple_Target


# Function run when node is added to scene
func _ready():
	# Skip if running in the editor
	if Engine.editor_hint:
		return

	# Ensure grapple length is valid
	var min_hook_length := 1.5 * ARVRServer.world_scale
	if grapple_length < min_hook_length:
		grapple_length = min_hook_length

	# Set ray-cast
	_grapple_raycast.cast_to = Vector3(0, 0, -grapple_length) * ARVRServer.world_scale #Is WS necessary here?
	_grapple_raycast.collision_mask = grapple_collision_mask

	# Deal with line
	_line.radius = rope_width
	_line.hide()


# Called before every frame update
func _process(delta: float):
	# Skip if invalid
	if !_controller:
		return

	# Update grapple button even if disabled
	var old_grapple_button := _grapple_button
	_grapple_button = _controller.is_button_pressed(grapple_button_id)
	
	# Calculate the new grappling state
	var old_grapple_state := grapple_state
	if !enabled or !_controller.get_is_active():
		# Grappling disabled, go to idle
		grapple_state = GrappleState.IDLE
	else:
		match old_grapple_state:
			GrappleState.IDLE:
				if _grapple_raycast.is_colliding():
					# IDLE -> TARGET
					grapple_state = GrappleState.TARGET

			GrappleState.TARGET:
				if !_grapple_raycast.is_colliding():
					# TARGET -> IDLE
					grapple_state = GrappleState.IDLE
				elif _grapple_button and !old_grapple_button:
					# TARGET -> FIRED
					hook_point = _grapple_raycast.get_collision_point()
					grapple_state = GrappleState.FIRED

			GrappleState.WINCHING:
				if !_grapple_button:
					# WINCHING -> IDLE
					grapple_state = GrappleState.IDLE

	# Handle state change
	if grapple_state != old_grapple_state:
		# Fire signals
		if grapple_state == GrappleState.FIRED:
			# Report grapple fired
			emit_signal("grapple_started")
		elif old_grapple_state == GrappleState.WINCHING:
			# Report end of winching
			emit_signal("grapple_finished")

		# Update active
		is_active = grapple_state != GrappleState.IDLE

		# Update visibility
		_line.visible = grapple_state >= GrappleState.FIRED
		_grapple_target.visible = grapple_state == GrappleState.TARGET

	# Update grapple line if visible
	if _line.visible:
		var line_length := (hook_point - _controller.global_transform.origin).length()
		_line_helper.look_at(hook_point, Vector3.UP)
		_line.height = line_length
		_line.translation.z = line_length / -2

	# Update grapple target if visible
	if _grapple_target.visible:
		_grapple_target.global_transform.origin  = _grapple_raycast.get_collision_point()
		_grapple_target.global_transform = _grapple_target.global_transform.orthonormalized()


# Perform grapple movement
func physics_movement(delta: float, player_body: PlayerBody):
	# Skip if not grappling
	if grapple_state < GrappleState.FIRED:
		return

	# Get hook direction
	var hook_vector := hook_point - _controller.global_transform.origin
	var hook_length := hook_vector.length()
	var hook_direction := hook_vector / hook_length

	# Apply gravity 
	player_body.velocity += Vector3.UP * player_body.gravity * delta

	# Select the grapple speed
	var speed := impulse_speed if grapple_state == GrappleState.FIRED else winch_speed
	if hook_length < 1.0:
		speed = 0.0

	# Transition from FIRED to WINCHING
	grapple_state = GrappleState.WINCHING

	# Ensure velocity is at least winch_speed towards hook
	var vdot = player_body.velocity.dot(hook_direction)
	if vdot < speed:
		player_body.velocity += hook_direction * (speed - vdot)

	# Scale down velocity
	player_body.velocity *= 1.0 - friction * delta

	# Perform exclusive movement as we have dealt with gravity
	player_body.velocity = player_body.move_and_slide(player_body.velocity)
	return true


# Called when the grapple collision mask has been modified
func _set_grapple_collision_mask(var new_value: int) -> void:
	grapple_collision_mask = new_value
	if is_inside_tree() and _grapple_raycast:
		_grapple_raycast.collision_mask = new_value


# This method verifies the MovementProvider has a valid configuration.
func _get_configuration_warning():
	# Check the controller node
	var test_controller = get_parent()
	if !test_controller or !test_controller is ARVRController:
		return "Unable to find ARVR Controller node"

	# Call base class
	return ._get_configuration_warning()

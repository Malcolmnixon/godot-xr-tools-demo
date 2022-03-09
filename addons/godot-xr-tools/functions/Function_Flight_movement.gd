tool
class_name Function_FlightMovement
extends MovementProvider

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

# Enumeration of controller to use for flight
enum FlightController {
	LEFT,		# Use left controller
	RIGHT,		# Use right controler
}

# Enumeration of pitch control input
enum FlightPitch {
	HEAD,		# Head controls pitch
	CONTROLLER,	# Controller controls pitch
}

# Enumeration of bearing control input
enum FlightBearing {
	HEAD,		# Head controls bearing
	CONTROLLER,	# Controller controls bearing
	BODY,		# Body controls bearing
}

# Vector3 for getting vertical component
const VERTICAL := Vector3(0.0, 1.0, 0.0)

# Vector3 for getting horizontal component
const HORIZONTAL := Vector3(1.0, 0.0, 1.0)


## Signal emitted when flight starts
signal flight_started()

## Signal emitted when flight finishes
signal flight_finished()


## Movement provider order
export var order := 30

## Flight controller
export (FlightController) var controller: int = FlightController.RIGHT

## Flight toggle button
export (Buttons) var flight_button: int = Buttons.VR_BUTTON_AX

## Flight pitch control
export (FlightPitch) var pitch: int = FlightPitch.CONTROLLER

## Flight bearing control
export (FlightBearing) var bearing: int = FlightBearing.CONTROLLER

## Flight speed from control
export var speed_scale: float = 5.0

## Flight traction pulling flight velocity towards the controlled speed
export var speed_traction: float = 3.0

## Flight acceleration from control
export var acceleration_scale: float = 0.0

## Flight drag
export var drag: float = 0.1

## Flight exclusive enable
export var exclusive: bool = true


# Flight button state
var _flight_button: bool = false

# Current flying state
var _is_flying: bool = false

# Flight controller
var _controller: ARVRController


# Node references
onready var _camera: ARVRCamera = ARVRHelpers.get_arvr_camera(self)
onready var _left_controller: ARVRController = ARVRHelpers.get_left_controller(self)
onready var _right_controller: ARVRController = ARVRHelpers.get_right_controller(self)


func _ready():
	# Get the flight controller
	if controller == FlightController.LEFT:
		_controller = _left_controller
	else:
		_controller = _right_controller

# Process physics movement for
func physics_movement(delta: float, player_body: PlayerBody):
	# Skip if the controller isn't active
	if !_controller.get_is_active():
		return

	# Detect press of flight button
	var old_flight_button = _flight_button
	_flight_button = _controller.is_button_pressed(flight_button)
	if _flight_button and !old_flight_button:
		# Toggle flying
		_is_flying = !_is_flying

		# Report change of flying state
		if _is_flying:
			emit_signal("flight_started")
		else:
			emit_signal("flight_finished")

	# Skip if not flying
	if !_is_flying:
		return

	# Select the pitch vector
	var pitch_vector: Vector3
	if pitch == FlightPitch.HEAD:
		# Use the vertical part of the 'head' forwards vector
		pitch_vector = -_camera.global_transform.basis.z.y * VERTICAL
	else:
		# Use the vertical part of the 'controller' forwards vector
		pitch_vector = -_controller.global_transform.basis.z.y * VERTICAL

	# Select the bearing vector
	var bearing_vector: Vector3
	if bearing == FlightBearing.HEAD:
		# Use the horizontal part of the 'head' forwards vector
		bearing_vector = -_camera.global_transform.basis.z * HORIZONTAL
	elif bearing == FlightBearing.CONTROLLER:
		# Use the horizontal part of the 'controller' forwards vector
		bearing_vector = -_controller.global_transform.basis.z * HORIZONTAL
	else:
		# Use the horizontal part of the 'body' forwards vector
		var left := _left_controller.global_transform.origin
		var right := _right_controller.global_transform.origin
		var left_to_right := (right - left) * HORIZONTAL
		bearing_vector = left_to_right.rotated(Vector3.UP, PI/2)

	# Construct the flight bearing
	var forwards := (bearing_vector.normalized() + pitch_vector).normalized()
	var side := forwards.cross(Vector3.UP)

	# Construct the target velocity
	var heading := forwards * _controller.get_joystick_axis(1) + side * _controller.get_joystick_axis(0)

	# Calculate the flight velocity
	var flight_velocity := player_body.velocity
	flight_velocity *= 1.0 - drag * delta
	flight_velocity = lerp(flight_velocity, heading * speed_scale, speed_traction * delta)
	flight_velocity += heading * acceleration_scale * delta
	
	# If exclusive then perform the exclusive move-and-slide
	if exclusive:
		player_body.velocity = player_body.move_and_slide(flight_velocity)
		return true
		
	# Update velocity and return for additional effects
	player_body.velocity = flight_velocity
	return

# This method verifies the MovementProvider has a valid configuration.
func _get_configuration_warning():
	# Call base class
	return ._get_configuration_warning()

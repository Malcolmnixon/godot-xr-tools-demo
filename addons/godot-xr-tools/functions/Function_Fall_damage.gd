tool
class_name Function_FallDamage
extends MovementProvider


## Signal invoked when the player takes fall damage
signal player_fall_damage(damage)


## Movement provider order
export var order := 1000

## Ignore damage if player is launched up
export var ignore_launch := true

## Only take damage on ground
export var ground_only := false

## Acceleration limit
export var damage_threshold := 8.0


# Previous velocity
var _previous_velocity := Vector3.ZERO


func _ready():
	# Set as always active
	is_active = true

func physics_movement(delta: float, player_body: PlayerBody, disabled: bool):
	# Skip if not enabled
	if disabled or !enabled:
		_previous_velocity = player_body.velocity
		return

	# Calculate the instantaneous acceleration
	var accel_vec := player_body.velocity - _previous_velocity
	_previous_velocity = player_body.velocity

	# Ignore launching the player
	var forgive := 0.0
	if ignore_launch:
		# Forgive "up" acceleration equal to our "up" speed
		accel_vec.y -= max(0, min(accel_vec.y, player_body.velocity.y));

	# Handle ground-only collisions
	if ground_only:
		# Ignore if not on ground
		if not player_body.on_ground:
			return

		# Only consider vertical acceleration
		accel_vec *= Vector3.UP

	# Detect fall damage
	var accel := accel_vec.length()
	if accel > damage_threshold:
		emit_signal("player_fall_damage", accel)

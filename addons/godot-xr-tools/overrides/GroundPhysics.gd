class_name GroundPhysics
extends Node


##
## Ground Physics Data
##
## @desc:
##     This script works with the GroundPhysics asset override the default
##     ground physics settings of the player when they are standing on a
##     specific type of ground.
##
##     In order to override the ground physics properties, the user must add a
##     GroundPhysics node to the object the player would stand on, then
##     enable the appropriate flags and provide new values.
##


## Enumeration flags for which ground physics properties are enabled
enum GroundPhysicsFlags {
	MOVE_DRAG = 1,
	MOVE_TRACTION = 2,
	MOVE_MAX_SLOPE = 4,
	JUMP_MAX_SLOP = 8,
	JUMP_VELOCITY = 16
}

## Flags defining which ground velocities are enabled
export (int, FLAGS, "Move Drag", "Move Traction", "Move Max Slope", "Jump Max Slope", "Jump Velocity") var override_flags := 0

## Movement drag factor
export var move_drag := 5.0

## Movement traction factor
export var move_traction := 30.0

## Movement maximum slope
export (float, 0.0, 85.0) var move_max_slope := 45.0

## Jump maximum slope
export (float, 0.0, 85.0) var jump_max_slope := 45.0

## Jump velocity
export var jump_velocity := 3.0

static func get_move_drag(override: GroundPhysics, default: float) -> float:
	if !override:
		return default
	elif override.override_flags & GroundPhysicsFlags.MOVE_DRAG:
		return override.move_drag
	else:
		return default

static func get_move_traction(override: GroundPhysics, default: float) -> float:
	if !override:
		return default
	elif override.override_flags & GroundPhysicsFlags.MOVE_TRACTION:
		return override.move_traction
	else:
		return default

static func get_move_max_slope(override: GroundPhysics, default: float) -> float:
	if !override:
		return default
	elif override.override_flags & GroundPhysicsFlags.MOVE_MAX_SLOPE:
		return override.move_max_slope
	else:
		return default

static func get_jump_max_slope(override: GroundPhysics, default: float) -> float:
	if !override:
		return default
	elif override.override_flags & GroundPhysicsFlags.JUMP_MAX_SLOP:
		return override.jump_max_slope
	else:
		return default

static func get_jump_velocity(override: GroundPhysics, default: float) -> float:
	if !override:
		return default
	elif override.override_flags & GroundPhysicsFlags.JUMP_VELOCITY:
		return override.jump_velocity
	else:
		return default

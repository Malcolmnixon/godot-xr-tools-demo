class_name VelocityAverager


##
## Velocity Averager class
##
## @desc:
##     This class assists in calculating the velocity (both linear and angular)
##     of an object. It accepts the following types of input:
##      - Periodic distances
##      - Periodic velocities
##      - Periodic transforms (for the origin position)
##
##     It provides the average velocity calculated from the total distance 
##     divided by the total time.
## 


# Count of averages to perform
var _count: int

# Array of time deltas (in float seconds) 
var _time_deltas := Array()

# Array of linear distances (in Vector3)
var _linear_distances := Array()

# Array of angular distances (in Quat)
var _angular_distances := Array()

# Last transform
var _last_transform := Transform()

# Has last transform flag
var _has_last_transform := false


## Initialize the VelocityAverager with an averaging count
func _init(var count: int):
	_count = count

## Clear the averages
func clear():
	_time_deltas.clear()
	_linear_distances.clear()
	_angular_distances.clear()
	_has_last_transform = false

## Add linear and angular distances to the averager
func add_distance(var delta: float, var linear_distance: Vector3, var angular_distance: Quat):
	# Add data averaging arrays
	_time_deltas.push_back(delta)
	_linear_distances.push_back(linear_distance)
	_angular_distances.push_back(angular_distance)

	# Keep the number of samples down to the requested count
	if _time_deltas.size() > _count:
		_time_deltas.pop_front()
		_linear_distances.pop_front()
		_angular_distances.pop_front()

## Add a transform to the averager
func add_transform(var delta: float, var transform: Transform):
	# Handle saving the first transform
	if !_has_last_transform:
		_last_transform = transform
		_has_last_transform = true
		return

	# Calculate the linear and angular distances
	var linear_distance := transform.origin - _last_transform.origin
	var angular_distance := (transform.basis * _last_transform.basis.inverse()).get_rotation_quat()
	
	# Update the last transform
	_last_transform = transform
	
	# Add distances
	add_distance(delta, linear_distance, angular_distance)

## Calculate the average linear velocity
func linear_velocity() -> Vector3:
	# Calculate the total time
	var total_time := 0.0
	for dt in _time_deltas:
		total_time += dt

	# Safety check to prevent division by zero
	if total_time <= 0.0:
		return Vector3.ZERO

	# Calculate the total distance
	var total_linear := Vector3.ZERO
	for dd in _linear_distances:
		total_linear += dd

	# Return the average
	return total_linear / total_time

## Calculate the average angular velocity as a Vector3 euler
func angular_velocity() -> Vector3:
	# Calculate the total time
	var total_time := 0.0
	for dt in _time_deltas:
		total_time += dt

	# Safety check to prevent division by zero
	if total_time <= 0.0:
		return Vector3.ZERO

	# Calculate the total angular distance
	var total_angular := Quat.IDENTITY
	for dd in _angular_distances:
		total_angular *= dd

	# Calculate the average
	return total_angular.get_euler() / total_time

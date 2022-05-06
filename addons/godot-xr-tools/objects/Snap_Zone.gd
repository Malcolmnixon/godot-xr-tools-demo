class_name XRTSnapZone
extends Area


## Signal emitted when the snap-zone picks something up
signal has_picked_up(what)

## Signal emitted when the snap-zone drops something
signal has_dropped

# Signal emitted when the highlight state changes
signal highlight_updated(pickable, enable)

# Signal emitted when the highlight state changes
signal close_highlight_updated(pickable, enable)

# Constant for worst-case grab distance
const MAX_GRAB_DISTANCE2: float = 1000.0


## Grab distance
export var grab_distance: float = 0.3 setget _set_grab_distance


# Public fields
var closest_object: Spatial = null
var picked_up_object: Spatial = null
var picked_up_ranged: bool = true


# Private fields
var _object_in_grab_area = Array()


func _ready():
	# Skip if running in the editor
	if Engine.editor_hint:
		return

	$CollisionShape.shape.radius = grab_distance


# Test if this object can be picked up
func can_pick_up() -> bool:
	return is_instance_valid(picked_up_object)


# Test if this object is picked up
func is_picked_up() -> bool:
	return false


# Called by Function_pickup when user presses the action button while holding this object
func action():
	pass


# This method is invoked when it becomes the closest pickable object to one of
# the pickup functions.
func increase_is_closest():
	#if is_instance_valid(picked_up_object):
	#TODO	picked_up_object.increase_is_closest()
	pass


# This method is invoked when it stops being the closest pickable object to one
# of the pickup functions.
func decrease_is_closest():
	pass


# Called by Function_pickup when this is picked up by a controller
func pick_up(by: Function_Pickup, with_controller: ARVRController) -> Spatial:
	if not is_instance_valid(picked_up_object):
		return null

	# Show highlight when empty
	emit_signal("highlight_updated", self, true)

	# Detach the object from us
	var target = picked_up_object
	picked_up_object = null
	target.let_go()

	# Force a remote grab
	by.picked_up_ranged = true

	# Have the target be picked up by the object
	return target.pick_up(by, with_controller)


# Called by Function_pickup when this is let go by a controller
func let_go(p_linear_velocity: Vector3, p_angular_velocity: Vector3):
	pass


# Called when the grab distance has been modified
func _set_grab_distance(var new_value: float) -> void:
	grab_distance = new_value
	if is_inside_tree() and $CollisionShape:
		$CollisionShape.shape.radius = grab_distance


# Called on each frame to update the pickup
func _process(delta):
	if is_instance_valid(picked_up_object):
		return

	for o in _object_in_grab_area:
		# skip objects that can not be picked up
		if not o.can_pick_up():
			continue

		# pick up our target
		picked_up_object = o.pick_up(self, null)
		if is_instance_valid(picked_up_object):
			emit_signal("has_picked_up", picked_up_object)
			emit_signal("highlight_updated", self, false)
			return



func _on_Snap_Zone_body_entered(target: Spatial) -> void:
	# reject objects which don't support picking up
	if not target.has_method('pick_up'):
		return

	# ignore objects already known
	if _object_in_grab_area.find(target) >= 0:
		return

	# Add to the list of objects in grab area
	_object_in_grab_area.push_back(target)

	# Show highlight when something could be snapped
	if not is_instance_valid(picked_up_object):
		emit_signal("close_highlight_updated", self, true)


func _on_Snap_Zone_body_exited(target: Spatial) -> void:
	_object_in_grab_area.erase(target)

	# Hide highlight when nothing could be snapped
	if _object_in_grab_area.empty():
		emit_signal("close_highlight_updated", self, false)


# Find the pickable object closest to our hand's grab location
func _get_closest_grab() -> Spatial:
	var new_closest_obj: Spatial = null
	var new_closest_distance := MAX_GRAB_DISTANCE2
	for o in _object_in_grab_area:
		# skip objects that can not be picked up
		if not o.can_pick_up():
			continue

		# Save if this object is closer than the current best
		var distance_squared := global_transform.origin.distance_squared_to(o.global_transform.origin)
		if distance_squared < new_closest_distance:
			new_closest_obj = o
			new_closest_distance = distance_squared

	# Return best object
	return new_closest_obj


func drop_object() -> void:
	if not is_instance_valid(picked_up_object):
		return

	# let go of this object
	picked_up_object.let_go()
	picked_up_object = null
	emit_signal("has_dropped")



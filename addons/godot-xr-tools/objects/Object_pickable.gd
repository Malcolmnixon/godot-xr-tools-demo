tool
extends RigidBody
class_name XRToolsPickable

# Set hold mode
export (bool) var press_to_hold = true
export (bool) var reset_transform_on_pickup = true
export  (int, LAYERS_3D_PHYSICS) var picked_up_layer = 0
export var can_ranged_grab: bool = true

# Remember some state so we can return to it when the user drops the object
onready var original_parent = get_parent()
onready var original_collision_mask = collision_mask
onready var original_collision_layer = collision_layer
var original_mode

# Who picked us up?
var picked_up_by = null
var center_pickup_on_node = null
var by_controller : ARVRController = null
var closest_count = 0

# Signal emitted when the user picks up this object
signal picked_up(pickable)

# Signal emitted when the user drops this object 
signal dropped(pickable)

# Signal emitted when the user presses the action button while holding this object
signal action_pressed(pickable)

# Signal emitted when the highlight state changes
signal highlight_updated(pickable, enable)

# have we been picked up?
func is_picked_up():
	if picked_up_by:
		return true

	return false

# action is called when user presses the action button while holding this object
func action():
	# let interested parties know
	emit_signal("action_pressed", self)

# This method is invoked when it becomes the closest pickable object to one of 
# the pickup functions.
func increase_is_closest():
	# Increment the closest counter
	closest_count += 1

	# If this object has just become highlighted then emit the signal
	if closest_count == 1:
		emit_signal("highlight_updated", self, true)

# This method is invoked when it stops being the closest pickable object to one
# of the pickup functions.
func decrease_is_closest():
	# Decrement the closest counter
	closest_count -= 1

	# If no-longer highlighted then emit the signal
	if closest_count == 0:
		emit_signal("highlight_updated", self, false)

func drop_and_free():
	if picked_up_by:
		picked_up_by.drop_object()

	queue_free()

# we are being picked up by...
func pick_up(by, with_controller):
	if picked_up_by == by:
		return

	if picked_up_by:
		let_go()

	# remember who picked us up
	picked_up_by = by
	by_controller = with_controller

	# Remember the mode before pickup
	original_mode = mode

	# turn off physics on our pickable object
	mode = RigidBody.MODE_STATIC
	collision_layer = picked_up_layer
	collision_mask = 0

	# now reparent it
	var original_transform = global_transform
	original_parent.remove_child(self)
	picked_up_by.add_child(self)

	if reset_transform_on_pickup or by.picked_up_ranged:
		if center_pickup_on_node:
			transform = center_pickup_on_node.global_transform.inverse() * global_transform
		else:
			# reset our transform
			transform = Transform()
	else:
		# make sure we keep its original position
		global_transform = original_transform

	# let interested parties know
	emit_signal("picked_up", self)

# we are being let go
func let_go(p_linear_velocity = Vector3(), p_angular_velocity = Vector3()):
	if picked_up_by:
		# get our current global transform
		var t = global_transform

		# reparent it
		picked_up_by.remove_child(self)
		original_parent.add_child(self)

		# reposition it and apply impulse
		global_transform = t
		mode = original_mode
		collision_mask = original_collision_mask
		collision_layer = original_collision_layer

		# set our starting velocity
		linear_velocity = p_linear_velocity
		angular_velocity = p_angular_velocity

		# we are no longer picked up
		picked_up_by = null
		by_controller = null
		
		# let interested parties know
		emit_signal("dropped", self)

func _ready():
	# Attempt to get the pickup center if provided
	center_pickup_on_node = get_node_or_null("PickupCenter")

func _get_configuration_warning():
	# Check for error cases when missing a PickupCenter
	if not find_node("PickupCenter"):
		if reset_transform_on_pickup:
			return "Missing PickupCenter child node for 'reset transform on pickup'"
		if can_ranged_grab:
			return "Missing PickupCenter child node for 'remote grabbing'"

	# No issues found
	return ""

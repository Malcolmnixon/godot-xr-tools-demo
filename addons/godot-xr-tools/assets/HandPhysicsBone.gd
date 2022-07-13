class_name XRToolsHandPhysicsBone
extends BoneAttachment


##
## XR Physics Hand Bone Script
##
## @desc:
##     This script adds a physics hand bone to a godot-xr-tools physics hand.
##
##     It extends from BoneAttachment to track the position of the bone in
##     the hand skeleton, and uses this position to move a CapsuleShape bone
##     StaticBody.
##
##     The bone StaticBody is set as top-level and manually driven with the 
##     bones positon and rotation. This is to prevent hand-scaling from scaling
##     the StaticBody collision shape as colliders cannot tolerate being scaled.
##
##     To handle scaling, this script subscribes to the hand_scale_changed signal
##     emitted by the XRToolsHand script and manually adjusts the CapsuleShape
##     to keep the collider scaled appropriately.
##
##     There are also additional collision and group settings for this specific
##     bone, which allows per-bone collision detection.
##


## Length of the bone
export var length := 0.03

## Ratio from length to width
export var width_ratio := 0.3

## Additional collision layer for this one bone
export (int, LAYERS_3D_PHYSICS) var collision_layer = 0

## Additional bone group for this one bone
export var bone_group := ""


# Bone shape
var _bone_shape : CapsuleShape

# Bone body
var _bone_body : StaticBody

# Bone middle
var _bone_middle : Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the 'hand_scale_changed' signal
	var physics_hand := _find_physics_hand()
	if physics_hand:
		physics_hand.connect("hand_scale_changed", self, "_on_hand_scale_changed")

	# Construct the bone shape
	_bone_shape = CapsuleShape.new()
	_bone_shape.margin = physics_hand.margin
	_on_hand_scale_changed(ARVRServer.world_scale)

	# Construct the bone collision shape
	var bone_collision := CollisionShape.new()
	bone_collision.set_name("BoneCollision")
	bone_collision.shape = _bone_shape
	bone_collision.transform.basis = Basis(Vector3.RIGHT, PI/2)

	# Construct the bone body
	_bone_body = StaticBody.new()
	_bone_body.set_name("BoneBody")
	_bone_body.set_as_toplevel(true)
	_bone_body.collision_layer = physics_hand.collision_layer | collision_layer
	_bone_body.add_child(bone_collision)

	# Set the optional bone group for all bones in the hand
	if not physics_hand.bone_group.empty():
		_bone_body.add_to_group(physics_hand.bone_group)

	# Set the optional bone group for this one bone
	if not bone_group.empty():
		_bone_body.add_to_group(bone_group)

	# Construct the bone middle spatial
	_bone_middle = Spatial.new()
	_bone_middle.transform.origin = Vector3.UP * length / 2

	# Add the bone body to this hand bone
	add_child(_bone_body)
	add_child(_bone_middle)


# Handle bone updating in the physics process
func _physics_process(_delta: float) -> void:
	# Get the bone transform
	var bone_xform = _bone_middle.global_transform

	# Set the bone position
	_bone_body.global_transform = Transform(
		Basis(bone_xform.basis.get_rotation_quat()),
		bone_xform.origin)


# Handle change of hand scale
func _on_hand_scale_changed(scale: float) -> void:
	# Get the scaled length and width
	var length_scaled := length * scale
	var width_scaled := length_scaled * width_ratio

	# Adjust the shape
	_bone_shape.radius = width_scaled
	_bone_shape.height = length_scaled


# Find the physics hand for this bone
func _find_physics_hand() -> XRToolsPhysicsHand:
	# Search up for a node with the 'hand_scale_changed' signal
	var current : Node = self
	while current:
		var hand := current as XRToolsPhysicsHand
		if hand:
			return hand
		current = current.get_parent()

	# Could not find hand
	return null

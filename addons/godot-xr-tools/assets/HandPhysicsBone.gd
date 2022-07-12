class_name XRToolsHandPhysicsBone
extends BoneAttachment


## Length of the bone
export var length: float = 0.03

## Ratio from length to width
export var width_ratio = 0.3

## Collision layer for this bone
export (int, LAYERS_3D_PHYSICS) var collision_layer = 1 << 17

## Collision mask for this bone
export (int, LAYERS_3D_PHYSICS) var collision_mask = 1023


# Bone shape
var _bone_shape : CapsuleShape

# Bone body
var _bone_body : StaticBody

# Bone middle
var _bone_middle : Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the 'hand_scale_changed' signal
	var hand := _find_hand()
	if hand:
		hand.connect("hand_scale_changed", self, "_on_hand_scale_changed")

	# Construct the bone hape
	_bone_shape = CapsuleShape.new()
	_bone_shape.margin = 0.004
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
	_bone_body.collision_layer = collision_layer
	_bone_body.collision_mask = collision_mask
	_bone_body.add_child(bone_collision)
	
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
		bone_xform.origin
	)


# Handle change of hand scale
func _on_hand_scale_changed(scale: float) -> void:
	# Get the scaled length and width
	var length_scaled = length * scale
	var width_scaled = length_scaled * width_ratio

	# Adjust the shape
	_bone_shape.radius = width_scaled
	_bone_shape.height = length_scaled


# Find the hand script for this bone
func _find_hand() -> Node:
	# Search up for a node with the 'hand_scale_changed' signal
	var current : Node = self
	while current:
		if current.has_signal("hand_scale_changed"):
			return current
		current = current.get_parent()

	# Could not find parent hand
	return null

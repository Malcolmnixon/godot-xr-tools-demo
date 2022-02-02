extends Spatial

export var player_body: NodePath

onready var player_body_node: PlayerBody = _get_player_body()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var position = player_body_node.kinematic_node.global_transform.origin
	$Sprite3D/Viewport/GridContainer/Position.text = str(position)
	
	var velocity = player_body_node.velocity.length()
	$Sprite3D/Viewport/GridContainer/Velocity.text = str(velocity)

	var ground = player_body_node.ground_node
	$Sprite3D/Viewport/GridContainer/Ground.text = str(ground)

	var slope = player_body_node.ground_angle
	$Sprite3D/Viewport/GridContainer/Slope.text = str(slope)

	var physics = player_body_node.ground_physics
	if physics and !physics.resource_name.empty():
		$Sprite3D/Viewport/GridContainer/Physics.text = physics.resource_name
	else:
		$Sprite3D/Viewport/GridContainer/Physics.text = str(physics)

# Get our origin node, we should be in a branch of this
func _get_arvr_origin() -> ARVROrigin:
	var parent = get_parent()
	while parent:
		if parent is ARVROrigin:
			return parent
		parent = parent.get_parent()
	
	return null
	
# Get our player body, this should be a node on our ARVROrigin node.
func _get_player_body() -> PlayerBody:
	# check if our property is set
	if player_body:
		return get_node(player_body) as PlayerBody

	# get our origin node
	var arvr_origin = _get_arvr_origin()
	if !arvr_origin:
		return null

	# checking if the node exists before fetching it prevents error spam
	if !arvr_origin.has_node("PlayerBody"):
		return null

	# get our player node
	var player_body = arvr_origin.get_node("PlayerBody")
	if player_body and player_body is PlayerBody:
		return player_body

	return null

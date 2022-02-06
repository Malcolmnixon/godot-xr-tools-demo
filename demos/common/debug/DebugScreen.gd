extends Spatial

var _player_body_node: PlayerBody = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !_player_body_node:
		_player_body_node = PlayerBody.get_player_body(self)
		
	var position = _player_body_node.kinematic_node.global_transform.origin
	$Sprite3D/Viewport/GridContainer/Position.text = str(position)
	
	var velocity = _player_body_node.velocity.length()
	$Sprite3D/Viewport/GridContainer/Velocity.text = str(velocity)

	var ground = _player_body_node.ground_node
	$Sprite3D/Viewport/GridContainer/Ground.text = str(ground)

	var slope = _player_body_node.ground_angle
	$Sprite3D/Viewport/GridContainer/Slope.text = str(slope)

	var physics = _player_body_node.ground_physics
	if physics and !physics.resource_name.empty():
		$Sprite3D/Viewport/GridContainer/Physics.text = physics.resource_name
	else:
		$Sprite3D/Viewport/GridContainer/Physics.text = str(physics)

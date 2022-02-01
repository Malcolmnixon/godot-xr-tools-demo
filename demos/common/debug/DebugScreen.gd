extends Spatial

export var player_body: NodePath

onready var player_body_node: PlayerBody = get_node(player_body)

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
	$Sprite3D/Viewport/GridContainer/Physics.text = str(physics)

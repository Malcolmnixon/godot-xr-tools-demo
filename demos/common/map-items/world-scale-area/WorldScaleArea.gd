extends Area


export var world_scale_min := 0.2

export var world_scale_max := 5.0

export var world_scale_rate := 2.0

var _active := false


func _physics_process(delta: float):
	# Skip if not active
	if not _active:
		set_physics_process(false)
		return

	# Calculate the time-based rate
	var time_rate = 1 + (world_scale_rate - 1) * delta

	# Update the world scale
	ARVRServer.world_scale = clamp(
		ARVRServer.world_scale * time_rate,
		world_scale_min,
		world_scale_max)


func _on_WorldScaleArea_body_entered(body: PhysicsBody):
	if body.is_in_group("player_body"):
		_active = true
		set_physics_process(true)


func _on_WorldScaleArea_body_exited(body: PhysicsBody):
	if body.is_in_group("player_body"):
		_active = false
		set_physics_process(false)

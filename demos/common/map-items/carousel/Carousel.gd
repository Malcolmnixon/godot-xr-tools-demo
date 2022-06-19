extends StaticBody


func _physics_process(delta):
	rotate_y(0.5 * delta)

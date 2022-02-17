extends Spatial



func _on_picked_up(_pickable):
	$PickedUp.play()


func _on_dropped(_pickable):
	$Dropped.play()


func _on_action_pressed(_pickable):
	$ActionPressed.play()

extends Spatial

func play_jump_sound():
	$JumpSound.play()


func _on_Function_Flight_movement_flight_started():
	$JetSound.play()


func _on_Function_Flight_movement_flight_finished():
	$JetSound.stop()

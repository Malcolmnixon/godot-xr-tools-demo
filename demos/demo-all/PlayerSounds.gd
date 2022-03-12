extends Spatial

func play_jump_sound():
	$JumpSound.play()


func _on_Function_Flight_movement_flight_started():
	$JetSound.play()


func _on_Function_Flight_movement_flight_finished():
	$JetSound.stop()


func _on_Function_Glide_movement_player_glide_start():
	$GlideSound.play()


func _on_Function_Glide_movement_player_glide_end():
	$GlideSound.stop()

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


func _on_Function_Grapple_movement_grapple_started():
	$WooshSound.play()
	$CreakSound.play()


func _on_Function_Grapple_movement_grapple_finished():
	$CreakSound.stop()


func _on_Function_Fall_damage_player_fall_damage(_damage: float):
	$FallSound.play()


func _on_PlayerBody_player_bounced(collider: PhysicsBody, magnitude: float):
	if collider.is_in_group("trampoline"):
		$TrampolineSound.play()

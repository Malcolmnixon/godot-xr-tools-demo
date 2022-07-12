extends Spatial



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float):
	var time10 := (OS.get_ticks_msec() % 10000) / 10000.0
	var angle := time10 * PI * 2
	var pos := sin(angle)
	
	$ElevatorBlock.transform.origin.y = pos * 5

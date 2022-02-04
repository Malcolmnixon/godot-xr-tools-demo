class_name VirtualKeyboard2D
extends CanvasLayer

# Shift key state
var _shift_key_pressed := false

# Caps-lock
var _caps_lock_down := false

# Current case visible
var _upper_case := false

# Handle key pressed from VirtualKey
func on_key_pressed(scan_code_text: String, unicode: int, shift: bool):
	# Find the scan code
	var scan_code := OS.find_scancode_from_string(scan_code_text)

	# Create the InputEventKey
	var input := InputEventKey.new()
	input.physical_scancode = scan_code
	input.unicode = unicode if unicode else scan_code
	input.pressed = true
	input.scancode = scan_code
	input.shift = shift

	# Dispatch the input event
	Input.parse_input_event(input)

	# Pop any temporary shift key
	if _shift_key_pressed:
		_shift_key_pressed = false
		_update_case()

# Handle shift-key press
func on_shift_key():
	# Evaluate key result
	if _upper_case:
		# Currently displaying upper-case, so clear all upper-case sources
		_shift_key_pressed = false
		_caps_lock_down = false
		$Background/Standard/ToggleCaps.set_pressed_no_signal(false)
	else:
		# Currently displaying lower-case, so enable upper-case by shift
		_shift_key_pressed = true

	# Update the case
	_update_case()

# Handle caps-lock toggle
func on_caps_toggle(button_pressed):
	# Save caps-lock state
	_caps_lock_down = button_pressed

	# Always clear shift when caps-lock is toggled
	_shift_key_pressed = false

	# Update the case
	_update_case()

# Update switching the visible case keys
func _update_case():
	# Decide which case should be visible
	var upper = _shift_key_pressed or _caps_lock_down
	if upper == _upper_case:
		return

	# Change the visible keys
	_upper_case = upper
	if _upper_case:
		$Background/UpperCase.visible = true
		$Background/LowerCase.visible = false
	else:
		$Background/LowerCase.visible = true
		$Background/UpperCase.visible = false

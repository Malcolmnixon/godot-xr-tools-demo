tool
class_name MovementProvider
extends Node

##
## Movement Provider base class
##
## @desc:
##     This MovementProvider class is the base class of all movement providers.
##     Movement providers are invoked by the PlayerBody object in order to apply
##     motion to the player
##
##     MovementProvider implementations should:
##      - Export an 'order' integer to control order of processing
##      - Override the physics_movement method to impelment motion
##

## Enable movement provider
export var enabled := true

# Override this function to apply motion to the PlayerBody
func physics_movement(delta: float, player_body: PlayerBody):
	pass

# This method verifies the MovementProvider has a valid configuration.
func _get_configuration_warning():
	# Verify movement provider is in the correct group
	if !is_in_group("movement_providers"):
		return "Movement provider not in 'movement_providers' group"

	# Verify order property exists
	if !"order" in self:
		return "Movement provider does not expose an order property"

	# Passed basic validation
	return ""

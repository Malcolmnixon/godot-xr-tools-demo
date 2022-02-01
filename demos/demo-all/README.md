# Demo Scene for Flying
This scene contains a player with the ability to fly.

## Player Construction
The following are the steps to create the player:
 - Create the player scene:
   - Inherited from godot-openxr/scenes/first_person_controller_vr.tscn
 - Add the left hand model:
   - Add godot-xr-tools/assets/LeftHand.tscn under LeftHandController
   - Change LeftHand translation to [-0.03, -0.05, 0.15]
 - Add the right hand model:
   - Add godot-xr-tools/assets/RightHand.tscn under RightHandController
   - Change RightHand translation to [0.03, -0.05, 0.15]
 - Add the player physics body:
   - Add godot-xr-hands/assets/PlayerBody.tscn under the player root ARVROrigin node
 - Add pickup support to the left and right hands:
   - Add godot-xr-tools/functions/Function_Pickup.tscn under LeftHandController and RightHandController
 - Add move/strafe support to the left hand:
   - Add godot-xr-tools/functions/Function_Direct_movement.tscn under LeftHandController
   - Enable "Smooth Rotation" if desired
   - Set "Move Type" to "Move And Strafe"
   - Set "Max Speed" to 3
 - Add move/rotate support to the right hand:
   - Add godot-xr-tools/functions/Function_Direct_movement.tscn under RightHandController
   - Enable "Smooth Rotation" if desired
   - Set "Move Type" to "Move And Rotate"
   - Set "Max Speed" to 3
 - Add jump movement support to the left and right hands:
   - Add godot-xr-tools/functions/Function_Jump_movement.tscn under LeftHandController and RightHandController
 - Add Climbing support to the player:
   - Add godot-xr-tools/functions/Function_Climb_movement.tscn under the player root ARVROrigin node
   - Set the Left Pickup to the Function_Pickup under the LeftHandController
   - Set the Right Pickup to the Function_Pickup under the RightHandController
 - Add Gliding support to the player:
   - Add godot-xr-tools/functions/Function_Glide_movement.tscn under the player root ARVROrigin node
 - Add Wind-push support to the player:
   - Add godot-xr-tools/functions/Function_Wind_movement.tscn under the player root ARVROrigin node

## Scene Construction
The following are the steps to create the scene:
 - Construct the 3D Scene
 - Add the Park map scene
 - Add the Player scene constructed above

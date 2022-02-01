# Demo Scene for Flying
This scene contains a player with the ability to fly.

## Player Construction
The following are the steps to create the player:
 - Create the player scene
   - Inherited from godot-openxr/scenes/first_person_controller_vr.tscn
 - Add the Left Hand
   - Add godot-xr-tools/assets/LeftHand.tscn under LeftHandController
   - Change LeftHand translation to [-0.03, -0.05, 0.15]
 - Add the Right Hand
   - Add godot-xr-tools/assets/RightHand.tscn under RightHandController
   - Change RightHand translation to [0.03, -0.05, 0.15]
 - Add the Player Physics Body
   - Add godot-xr-hands/assets/PlayerBody.tscn under the player root ARVROrigin node
 - Add Direct Movement support to the Left Hand
   - Add godot-xr-tools/functions/Function_Direct_movement.tscn under LeftHandController
   - Enable "Smooth Rotation" if desired
   - Set "Move Type" to "Move And Strafe"
   - Set "Max Speed" to 3
   - Ensure "Can Fly" is enabled
 - Add Direct Movement support to the Right Hand
   - Add godot-xr-tools/functions/Function_Direct_movement.tscn under RightHandController
   - Enable "Smooth Rotation" if desired
   - Set "Move Type" to "Move And Rotate"
   - Set "Max Speed" to 3
   - Ensure "Can Fly" is enabled
 - Set priorities so rotation works when flying with either hand
   - Set the "Order" of the Left Hand Function_Direct_movement is 10
   - Set the "Order" of the Right Hand Function_Direct_movement is 11
   - This will guarantee the Rotation of the Right hand is performed before any flight for the left hand terminates motion rules

## Scene Construction
The following are the steps to create the scene:
 - Construct the 3D Scene
 - Add the Park map scene
 - Add the Player scene

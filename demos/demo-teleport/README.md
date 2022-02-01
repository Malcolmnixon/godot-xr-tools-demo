# Demo Scene for Teleport
This scene contains a player with the ability to teleport.

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
 - Add teleport to the left and right hands
   - Add godot-xr-tools/functions/Function_Teleport.tscn under LeftHandController and RightHandController

## Scene Construction
The following are the steps to create the scene:
 - Construct the 3D Scene
 - Add the Park map scene
 - Add the Player scene constructed above

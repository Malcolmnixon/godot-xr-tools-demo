# Overview
This is a demo project to show off different godot-xr-tools movement mechanics.

# Teleport Demo
The demos/demo-teleport/DemoTeleport scene demonstrates using teleport mechanics to move around the map.

The associated [README.md](demos/demo-teleport/README.md) contains the overview of creating the teleport player.


# Flying Demo
The demos/demo-flying/DemoFlying scene demonstrates support for flying. It introduces a physics body to the player to ensure
the player cannot fly through physical structures.

The associated [README.md](demos/demo-flying/README.md) contains the overview of creating the player with basic direct movement and flying support.

# All Demo
The demos/demo-all/DemoAll scene demonstrates support for all of the movement mechanics, specifically:
 - Direct movement (including strafing)
 - Jumping
 - Climbing
 - Gliding
 - Wind blown

The map contains numerous objects to test out the different mechanics, including:
 - An ice-rink with low traction
 - A jump spot which greatly enhances the players jump height
 - Three wind areas that can blow the player along the ground or up into the air

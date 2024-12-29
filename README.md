# Morphframe

## What is it?
- a tool for easily making interpolated 2d animations
- made in godot
- currently unusably unfinished
- based of the principle of "frames" that are intelligently "morphed" from one to the next

## Issues / Minor Feature Tweaks:
- Fine grain rotation unintuitive
- Skew is calcuated wrong
- `player_holder.gd` needs to be cleaned up
- savefiles need git compadable option (aka not zipped up + `.gitnore`)

## Implemented:
- Navigation
- Images
- Selection
- Selection Box Handles
- Undo/Redo
- Save/Loading
- Asset Management

## Todo for MVP:
- Toolbar actions:
  - z-layer modification
  - Transparency / Blend mode
  - Delete
- "Frames"
  - Selecting only certain parts of a frame to count as modified
- Copy/Paste
- "Morphing"
  - Interpolation modes
- Exporting as video
  - Pre recorded timings mode
  - Live/Manual frame changing (like presentation software)

# Todo beyond MVP:
- Audio Object
- Text Object
- Video Object
  - potentially record video
- Live Webcam Object
- Record Audio & Camera Video & Screen Capture
- Drawing
- Controllers & Groups
  - like geometry dash tiggers
  - like blender armatures
  - like blender drivers
- Embeded animation scenes
  - like a walk animation that plays during a morph and itself is a selection of morphs
  - this kinda goes against the design philosophy so imma need to cook on this a while longer
  - could be related to controllers & groups or might be completely unrelated idk yet

## Goal
Create animations to **illistrate complex proccess visually extreemly quickly**

## Design Pillars:
- High quality UX (it mustn't be annoying to use)
- Keyframe/Slide based (immediatly obvious how any part will look at all times) (like a presentaiton with slides)
- Morph between each frame intelegently (minimally configurable - any configuration must be viewable in the frame selector on the side)
- More complex animations possible with groups/controlers & embeded scenes

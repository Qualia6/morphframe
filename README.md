# MorphFrame

## What is it?
- a tool for easily making interpolated 2d animations
- made in godot
- currently unusably unfinished
- based of the principle of "frames" that are intelligently "morphed" from one to the next

## Issues / Minor Feature Tweaks:
- Fine grain rotation unintuitive
- Skew is calculated wrong
- `player_holder.gd` needs to be cleaned up
- save files need git compadable option (aka not zipped up + `.gitignore`)

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

## Todo beyond MVP:
- Audio Object
- Text Object
- Video Object
- Live Webcam Object
- Record Audio & Camera Video & Screen Capture
- Drawing
- Controllers & Groups
  - like geometry dash triggers
  - like blender armatures
  - like blender drivers
- Embedded animation scenes
  - like a walk animation that plays during a morph and itself is a selection of morphs
  - this kinda goes against the design philosophy so imma need to cook on this a while longer
  - could be related to controllers & groups or might be completely unrelated idk yet

## Goal
Create animations to **illustrate complex process visually extremely quickly**

## Design Pillars:
- High quality UX (it mustn't be annoying to use)
- Keyframe/Slide based (immediately obvious how any part will look at all times) (like a presentation with slides)
- Morph between each frame intelligently (minimally configurable - any configuration must be viewable in the frame selector on the side)
- More complex animations possible with groups/controllers & embedded scenes

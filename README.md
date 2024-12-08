# Morphframe

## What is it?
- a tool for easily making interpolated 2d animations
- made in godot
- currently unusably unfinished
- based of the principle of "frames" that are intelligently "morphed" from one to the next

## Issues:
- Fine grain rotation unintuitive
- Skew is calcuated wrong
- `player_holder.gd` needs an entier rewrite eventually

## Implemented:
- Navigation
- Images
- Selection
- Undo/Redo

## Todo:
- Save/Loading
  - add deleting of images too
  - make importing the same image twice references the same file
- Toolbar actions:
  - z-layer modification
  - Transparency / Blend mode
- Copy/Paste
- "Frames"
  - Selecting only certain parts of a frame to count as modified
- "Morphing"
  - Interpolation modes
- Exporting as video
- Armatures & Groups
  - groups are a type of armature
- Audio Track(s)
  - potentially record audio
- Text
- Video
  - potentially record video
  - potentially include a live webcam 
- Embeded animation scenes
  - like a walk animation that plays during a morph and itself is a selection of morphs
  - this kinda goes against the design philosophy so imma need to cook on this a while longer

## Goal
Create animations to **illistrate complex proccess visually extreemly quickly**

## Design Pillars:
- High quality UX (it mustn't be annoying to use)
- Keyframe/Slide based (immediatly obvious how any part will look at all times) (like a presentaiton with slides)
- Morph between each frame intelegently (minimally configurable - any configuration must be viewable in the frame selector on the side)
- More complex animations possible with armatures (groups will be a type of armature)

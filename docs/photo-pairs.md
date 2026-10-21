# Photo pairs: the real place and the game

For a game in a real place, the question "does it look like the place?" needs proof, not an opinion. A photo pair shows
a real photo and the game from the same point, in the same direction, with the same field of view.

## 1. The method

1. **Reference photos.** Find photos with a known camera point and direction, for example files on Wikimedia Commons
   with a location template on the file page. A geosearch of the Commons API near each place finds them. Keep only the
   photos that look at the place. Record the licence, the author, and the link of each photo.
2. **Check the camera.** Some photos have a wrong point or direction (a point on a roof, a direction to the other side).
   Leave them out, or fit the camera from the photo: the bearings of three known corners, or 5 to 7 points of a building
   with their pixels and heights.
3. **The game views.** A PlayMode tool test (categories `Level` and `Tool`, so that no tier runs it) reads a file of
   views: `VIEW <tag> <x> <z> <heading> [pitch] [fov] [eye height]`. For each view it loads the parts of the level
   around the point, waits for the loads, and renders two images:
   - the normal look of the game (light, fog, post effects);
   - a flat-light version (no fog, no post effects, a grey ambient and one sun), which shows the shapes.
   Run it through the runner: `tools/unity-lock.sh tools/test-one.sh PlayMode <ShotsTestClass>`.
4. **Sheets.** One sheet for each pair: the real photo, the game before the change, the game after the change. Use the
   same order on each sheet.
5. **Scores with proof.** Give each area a score from 0 to 10, with the proof next to it: the street map, the places and
   outlines of buildings, the heights, the roofs, the fronts, the landmarks, the street furniture. Measure what can be
   measured (for example "the eave height is within 1.2 m of the data for 80 % of the houses").
6. **A plan.** Rank the fixes by the visible gain for the effort. Give the human the decisions with a cost.

## 2. Also measure the first view

Render the first view of a game from each start place. The human sees this view first. In the tested game, one start
place faced a building that the human did not recognise, and that one view started the whole check.

## 3. What this method does not show

- It compares shapes and places, not the feel of a street at play speed. The human play report covers that.
- A photo from one day and one season can show shop signs, trees, and works that differ from the game. Compare the
  permanent parts.

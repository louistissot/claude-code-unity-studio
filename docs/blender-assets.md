# 3D models from Blender scripts

A Blender asset session makes models with Python scripts that Blender runs in batch mode. Each model can be made again
at any time from the data and the scripts in the repository. Nobody edits a model only by hand in the Blender window.

## 1. Files

| Path | Contents |
|---|---|
| `tools/blender/<kit>/kit.py` | The shared kit: frames, a mesh builder with UVs in metres, walls with real openings, mouldings, lathe forms, roofs, materials, LODs, the FBX export. |
| `tools/blender/<kit>/<model>.py` | One script for each model. |
| `tools/blender/<kit>/data/<model>.json` | The data of each model (outline, heights, measures). No download is needed to make the model again. |
| `tools/blender/<kit>/proof.py`, `views.json` | The proof renders from the camera of each reference photo. |
| `Assets/Art/<Kit>/<Model>/<Model>.fbx` | The meshes `<Model>_LOD0`, `_LOD1`, `_LOD2`. |
| `Assets/Art/<Kit>/<Model>/<Model>_Collider.fbx` | One simple mesh for a MeshCollider. |
| `Assets/Art/<Kit>/materials.json` | The material table that the kit writes and an Editor script reads. |
| `Assets/Editor/<Kit>/<Kit>Assets.cs` | The Unity setup (materials, import settings, prefabs) and the checks. |

Commands (from the project folder):

```bash
blender -b --factory-startup --python tools/blender/<kit>/<model>.py
```

```bash
tools/unity-lock.sh tools/batch.sh <Kit>Assets.SetupAndCheck
```

On macOS the Blender binary is `/Applications/Blender.app/Contents/MacOS/Blender`. `--factory-startup` keeps the
settings and add-ons of the user out of the run, so that each run gives the same result.

## 2. Method

1. **Data first.** Take the outline from the data of the game (the outline that the level uses), so that the walls
   stand on the same line as the level. Take heights and roof shapes from open data where it exists, and from photos
   where it does not. Mark each height that comes from a photo as an estimate.
2. **Frames.** Write down each conversion: the map frame, the frame of the level, the frame of the model in Blender.
   In the tested setup, an FBX export with forward -Z, up Y, and "apply transform", then the Unity import, gave Unity
   (x, y, z) = (-Blender x, Blender z, -Blender y). Check this in your project: compare the bounds of each imported
   LOD0 in Unity with the bounds that Blender wrote (within 0.1 m). Then the axes, the mirror, and the scale are right.
3. **Hand-made and hybrid parts.** Make the important fronts and the towers by hand in code. Use the open data for the
   roofs and the back parts. Walls get real openings (reveals, panes at depth, frames, sills) in LOD0.
4. **LODs and a budget.** LOD0 with all details (set a triangle budget, for example 60 000); LOD1 without frames and
   small parts; LOD2 with the mass, the roofs, and the panes on the faces. The collider is a few prisms and boxes.
5. **Materials by name.** The FBX keeps only the material names. The Unity setup makes the materials from
   `materials.json`. UVs are in metres, so the UV scale of a texture is 1 divided by the size of its tile in metres.
   Colours come from the photos (sRGB), as a tint for a free texture.
6. **Proof.** For each reference photo: the camera of the photo (from the photo itself; GPS points of phone photos were
   wrong by 20 to 30 m), the model, the buildings around it as grey masses, a day render and a night render, on one
   sheet with the photo.
7. **Report.** Each script writes a report: the triangles of each LOD and of each material, and the bounds.
8. **Unity check.** One import check through the runner: the materials, the prefabs, three LODs, LOD0 within the budget,
   a collider, the bounds equal to the Blender bounds. Put the same checks in an EditMode test.

## 3. Licences

Use free textures (CC0 first) and record each file (name, source, size, licence) in a credits file. Use reference
photos only for the proof and for the reading of the shapes, and record their licence and author. Check the licence of
open 3D data before you copy shapes from it; some sources allow the data but not the code of their viewers.

## 4. A Blender connection for Claude

A Blender MCP server lets a session look at a scene in the Blender window. It helps for a question about a scene. The
models themselves come from the scripts in batch mode, so that they can be made again.

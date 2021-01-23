Horizontal Timing

|Legend |Description         | 
|-------|--------------------|
|A      |scanline time       |
|B      |Sync pulse length   |
|C      |Back porch          |
|D      |Active video time   |
|E      |Front porch         |

```
Video
            ______________________             ___________________
___________| VIDEO                |___________| VIDEO (next line)
       |-C-|----------D-----------|-E-|   |-C-|----------D-------
Hsync
__     _______________________________     ___________
  |___|                               |___| 
  |-B-|                               |-B-| 
  |---------------A-------------------|
```
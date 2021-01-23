Horizontal Timing

|   |   |   |   |   |
|---|---|---|---|---|
|A   |scanline time   |   |   |   |
|B   |Sync pulse length   |   |   |   |
|C   |Back porch   |   |   |   |
|D   |Active video time   |   |   |   |
|E   |Front porch   |   |   |   |

```
Video
         ______________________          ___________________
________| VIDEO                |________| VIDEO (next line)
    |-C-|----------D-----------|-E-|

Hsync
__   _______________________________   ___________
  |_|                               |_| 
  |B|
  |---------------A-----------------|
```
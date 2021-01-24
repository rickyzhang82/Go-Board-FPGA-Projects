Horizontal Timing
=================

- Signal Timing

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

The horizontal sync pulse marks the beginning and the end of one line.

Vertical Timing
===============

- Signal Timing

The vertical sync pulse marks the beginning and the end of one frame.

![signal](vga-signal-format.png)

Standard VGA 640x480@60Hz
=========================


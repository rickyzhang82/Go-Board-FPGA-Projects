Horizontal Timing
=================

- Signal Timing

|Legend |Description         | 
|-------|--------------------|
|A      |scanline time       |
|B      |Sync pulse length   |
|C      |Front porch         |
|D      |Active video time   |
|E      |Back porch          |


```
Video
            ______________________             ___________________
___________| VIDEO                |___________| VIDEO (next line)
       |-C-|----------D-----------|-E-|   |-C-|----------D-------

Hsync

When HSYNC = 1, line video is active. = Front Porch (C) + Active Video (D) + Back Porch (E)
When HSYNC = 0, line video is inactive.
The rising HSYNC signal triggers horizontal video line.

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
The rising VSYNC signal triggers a video frame.

![signal](vga-signal-format.png)

Standard VGA 640x480@60Hz
=========================

At 25.175 MHz, T= 39.72194637537239 ns

60 frame/s, 800 x 525 pixel/ frame => 1 /60 / (800x525) = 39.68253968253968 ns/ pixel

Horizontal timing

| Scanline part| Pixels | Time [µs]|
|--------------|--------|----------|
|Visible area  |640     |25.422045680238|
|Front porch   |16      |0.63555114200596|
|Sync pulse    |96      |3.8133068520357|
|Back porch    |48      |1.9066534260179|
|Whole line    |800     |31.777557100298|


Vertical timing

|Frame part     |Lines  |Time [ms]|
|---------------|-------|---------|
|Visible area   |480    |15.253227408143|
|Front porch    |10     |0.31777557100298|
|Sync pulse     |2      |0.063555114200596|
|Back porch     |33     |1.0486593843098|
|Whole frame    |525    |16.683217477656|

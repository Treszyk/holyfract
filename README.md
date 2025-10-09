# HolyFract

A minimal Mandelbrot fractal renderer written in **HolyC** for **TempleOS**.  
Renders a Mandelbrot set to the screen and allows basic navigation and zoom using keyboard input.

# Overview

holyfract implements a simple iterative Mandelbrot fractal visualizer.  
Rendering is performed directly to a device context (**CDC** in **TempleOS**) using per-pixel iteration counts to determine the pixel color.

# Features

- Gradient fractal rendering  
  Basic Mandelbrot visualization in different shades of purple

- Keyboard navigation  
  Arrow keys pan across the complex plane.  
  [ **A** ] zooms in, [ **D** ] zooms out.

- Configurable iteration limit  
  The maximum iteration depth is currently fixed to 128, but can be adjusted for precision vs performance.

- Coordinate mapping  
  Screen-space coordinates are converted to complex-space using the current center (**M_CX**, **M_CY**) and scale factor.

# Controls

| Key           | Action       |
| ------------- | ------------ |
| ↑ / ↓ / ← / → | Move view                         |
| A             | Zoom in                           |
| D             | Zoom out                          |
| M             | Set max iterations to 1024        |
| N             | Set max iterations to default 128 |
| ESC           | Exit program |

# Implementation Details

## Coordinate Mapping

Each pixel (**x**, **y**) is mapped to a complex coordinate (**re**, **im**) using:

    re = M_CX + (x - (GR_WIDTH / 2)) * scale
    im = M_CY + (y - (GR_HEIGHT / 2)) * scale

This ensures the fractal remains centered on the current viewport origin.

## Iteration Function

The core iteration loop:

    zr, zi = 0
    for i in 0..max_iter:
        if zr² + zi² > 4 → escape
        zi = 2*zr*zi + im
        zr = zr² - zi² + re

Returns the iteration count where the iterations escape to infinity, or max_iter if the point remains bounded.

## Rendering

Each pixel’s iteration count is converted to a shade of purple:

```
U32 MandelColor(I64 iter, I64 max_iter)
{
    if (iter >= max_iter || iter <= 4) return 0;

    F64 t = iter(F64) / max_iter(F64);
    t = Sqrt(t);
    I64 idx = 1 + (t * 14.0)(I64);

    if (idx > 15) idx = 15;
    return (iter >> 3) & (COLORS_NUM - 1);
}
```

Color logic is isolated in MandelColor(). And setting the palette is handled in ApplyFractalPalette():
```
U0 ApplyFractalPalette()
{
    I64 i;
    CBGR48 bgr;

    GrPaletteColorSet(0, 0x000000);
    for (i = 1; i < COLORS_NUM; i++)
    {
        I64 v = (0xFFFF * i) / (COLORS_NUM - 1);
        bgr.r = v >> 1;
        bgr.g = 0;
        bgr.b = v;

        GrPaletteColorSet(i, bgr);
    }
}
```

## Performance

Current implementation performs direct per-pixel iteration and rendering. This means that on higher zoom levels where iterations increase the math slows down heavily.  
Optimization is planned through progressive rendering with a couple of different **LOD** levels.

# Preview

![gradient_holyfractv1](https://github.com/user-attachments/assets/8d68ebe8-e137-4848-8d44-d65007c62d6e)
*Initial gradient render – 128 iterations per pixel*

![gradient_holyfractv2](https://github.com/user-attachments/assets/73c66076-7cc2-4e77-82d0-0dafd6b8ff96)
*Zoomed in view of the fractal - 4096 iterations per pixel*

# Known Limitations

- Input buffer flush is handled manually with:

      while (ScanKey(&ch, &sc)) { }
  Needs to be replaced with a proper buffer flush method once available.

- No progressive rendering or caching.
- Framerate drops significantly at high zoom levels.

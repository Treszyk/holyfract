# HolyFract

A minimal Mandelbrot fractal renderer written in **HolyC** for **TempleOS**.  
Renders a monochromatic Mandelbrot set to the screen and allows basic navigation and zoom using keyboard input.

# Overview

holyfract implements a simple iterative Mandelbrot fractal visualizer.  
Rendering is performed directly to a device context (**CDC** in **TempleOS**) using per-pixel iteration counts to determine the pixel color.

# Features

- Monochromatic fractal rendering  
  Basic Mandelbrot visualization in black and white.

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
| ↑ / ↓ / ← / → | Move view    |
| A             | Zoom in      |
| D             | Zoom out     |
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

Each pixel’s iteration count is converted to a monochrome value:

    iter == max_iter → BLACK
    else             → WHITE

Color logic is isolated in MandelColor(). Though the color logic is very simple now it will make the implementation of more values easier.

## Performance

Current implementation performs direct per-pixel iteration and rendering. This means that on higher zoom levels where iterations increase the math slows down heavily.  
Optimization is planned through progressive rendering with a couple of different **LOD** levels.

# Preview

![holyfractv1](https://github.com/user-attachments/assets/244f12d6-1a91-4b00-b817-548bec5826c0)
*Initial monochrome render – 128 iterations per pixel*

![holyfractv2](https://github.com/user-attachments/assets/27225f15-2aad-48e6-88d8-853ebb99ae28)
*Zoomed in view of the fractal - 256 iterations per pixel*

# Known Limitations

- Input buffer flush is handled manually with:

      while (ScanKey(&ch, &sc)) { }
  Needs to be replaced with a proper buffer flush method once available.

- No progressive rendering or caching.
- Framerate drops significantly at high zoom levels.

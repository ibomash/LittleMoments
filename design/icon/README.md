# Little Moments — warm horizon

A spacious dusk icon with a peach sun, a low blue horizon, and one rising sea-glass sweep. Original vector artwork based on the top-left concept and subsequent direction in the shared conversation.

## Files

- `little-moments.svg`: complete editable 1024 × 1024 composition, with named groups. Includes illustrative gradients, atmospheric glow, transparency, and an edge highlight.
- `layers/02-sun.svg`, `03-horizon.svg`, `04-foreground.svg`: clean, opaque vector shapes for Icon Composer. Each preserves the same 1024 × 1024 canvas and coordinates. No embedded images, filters, masks, shadows, or baked glass effects.
- `preview.svg` / `preview.png`: presentation only, with an approximate continuous-corner mask. This is an art-direction preview, not an Icon Composer render.

## Icon Composer setup

1. Create a 1024 × 1024 icon. Set its native background to a vertical gradient from dusky blue `#293B61` to warm peach `#EAC0A3`. Position the warm end around the horizon. The master SVG has a richer multistop sky for visual reference; the native two-color gradient will differ slightly.
2. Import the three files in `layers/`. Use one group per shape, ordered sun → horizon → foreground from back to front. Retain original canvas alignment and scale; do not crop SVGs to their visible bounds.
3. Keep the sun nearly solid, with a soft gradient from `#FFE0AF` to `#F3B88F`. Disable its Liquid Glass effects initially.
4. Keep the distant horizon dark and quiet (`#345A75` to `#244461`); disable its Liquid Glass effects initially.
5. Use the foreground as the main glass element. Try a pale blue `#CAE0DF` to muted blue `#468CAB` gradient, restrained translucency and blur, minimal shadow, and a subtle specular edge. Adjust while previewing; these are visual starting points, not verified numeric presets.
6. Let Icon Composer apply the outer icon mask. Review default, dark, clear, and tinted appearances and small sizes before integrating into the app.

The production SVG layers intentionally omit the sky and simulated material effects, following [Apple's artwork preparation guidance](https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer). The sky is the native Composer background. Do not import the complete master or the masked preview as a single production layer.

Validation: all SVGs parsed as XML and rendered with librsvg. Preview visually inspected. Import and dynamic material rendering in Icon Composer remain to be done. No application behavior or asset catalog was changed.

## Project integration

`Little Moments.icon` is the canonical app icon resource selected by `Project.swift`. It includes four SVG layers and Dark appearance overrides. The previous raster AppIcon catalog has been removed. The SVGs and previews elsewhere in this folder are design references; edit the `.icon` document for production changes. Both iOS and native macOS targets use this shared icon document.

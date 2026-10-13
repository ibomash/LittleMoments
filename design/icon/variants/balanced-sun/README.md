# Balanced sun — assembled in Icon Composer

Sun diameter: 237.6 on a 1024 canvas (90% of the larger variant). Center remains (323, 350).

The saved Composer document is `../../Little Moments.icon`. It contains four independently editable groups, from back to front: Sky, Sun, Horizon, Glass Sweep. Its SVG assets are embedded in the document package.

`composer-layers/` preserves the artwork gradients but removes the simulated glow, highlight stroke, and opacity. The sky is an opaque vector layer to retain the multistop dusk gradient. Glass effects are disabled for sky, sun, and horizon.

Foreground material: automatic specular highlight, blur 15%, translucency 30%, no shadow, refraction strength 15% and depth 10%. Refraction applies to design generation 27; generation 26 was also visually checked. Default, dark, and monochrome previews were inspected. Dark uses 80% sky group opacity over the native dark background and 90% foreground group opacity; the warm sun stays unchanged. These overrides apply only to Dark.

Created and saved using Icon Composer UI. The document is left open in default appearance with generation 26 preview selected. `../../composer-preview.png` shows the actual app rendering. The app target references this document directly through Project.swift; the legacy AppIcon asset catalog has been removed.

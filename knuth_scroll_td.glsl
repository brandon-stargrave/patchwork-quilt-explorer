// Knuth Bitwise Fractal — Scrolling Version
// TouchDesigner GLSL TOP — Pixel Shader
//
// SETUP:
//   1. Create a GLSL TOP (or GLSL Multi TOP)
//   2. Set the output resolution to your desired size (e.g. 1920x1080)
//   3. Paste this code into the Pixel Shader parameter
//   4. Create a custom uniform "uScrollOffset" (float) and drive it with
//      a CHOP (e.g. LFO, Timer, or absTime.seconds) for animation,
//      OR just use the built-in absTime.seconds as shown below.
//
// CUSTOMIZATION:
//   - SCROLL_SPEED: pixels per second of scroll
//   - INVERT: flip black/white
//   - GLITCH_25: only affect 25% of pixels for a subtler effect
//   - DOCKREY: swap X/Y axes for the Dockrey variant
//

// ── Custom uniforms (optional, create in GLSL TOP parameters page) ──
// uniform float uScrollOffset;   // If you want manual control

// ── Configuration ──
#define SCROLL_SPEED  60.0
#define START_OFFSET  350
#define INVERT        0
#define GLITCH_25     1
#define DOCKREY       0

out vec4 fragColor;

void main()
{
    // ── Pixel coordinates ──
    // TouchDesigner's vUV.st is 0–1; convert to integer pixel coords
    vec2 resolution = uTDOutputInfo.res.zw;
    ivec2 px = ivec2(vUV.st * resolution);

    int x = px.x;
    int y = px.y;

    // ── Time / scroll offset ──
    // Use TouchDesigner's built-in absTime.seconds
    // Replace with uScrollOffset if driving manually
    float timeSeconds = absTime.seconds;
    int t = START_OFFSET - int(timeSeconds * SCROLL_SPEED);

    // ── Knuth bitwise fractal core ──
    //
    // From Knuth, The Art of Computer Programming vol 4A:
    //   (((x ^ ~y) & ((y - t) >> 3))² >> 12) & 1
    //
    // The squaring + right-shift creates self-similar fractal structure.
    // The XOR with complement creates the base interference pattern.
    // The scrolling (y - t) >> 3 slides the mask over time.

    int l, r, scrollAxis;

#if DOCKREY
    l = y;
    r = ~x;
    scrollAxis = x;
#else
    l = x;
    r = ~y;
    scrollAxis = y;
#endif

    int masked = (l ^ r) & ((scrollAxis - t) >> 3);
    int squared = masked * masked;
    int shifted = squared >> 12;

#if GLITCH_25
    bool bit = (shifted & 3) != 0;
#else
    bool bit = (shifted & 1) != 0;
#endif

#if INVERT
    float c = bit ? 1.0 : 0.0;
#else
    float c = bit ? 0.0 : 1.0;
#endif

    // ── Output ──
    fragColor = TDOutputSwizzle(vec4(c, c, c, 1.0));
}

// Knuth Bitwise Fractal — Scrolling Version
// GLSL fragment shader for TouchDesigner GLSL TOP
//
// Setup in TouchDesigner:
//   1. Create a GLSL TOP
//   2. Paste this into the "Pixel Shader" (glsl1_pixel)
//   3. The uniform uTime is automatically available via TouchDesigner's
//      built-in time. Or drive it manually with a CHOP → uniform.
//   4. Resolution is taken from the TOP's output resolution.
//
// Uniforms provided by TouchDesigner:
//   uniform float uTime;          — elapsed time in seconds
//   uniform vec2  uResolution;    — output resolution
//
// If your TouchDesigner version uses different names, adjust below.

// TouchDesigner provides these automatically for GLSL TOPs:
// out vec4 fragColor;   (output)
// in vec2 vUV;          (0–1 texture coordinates)

uniform float uTime;

// Scroll speed and starting offset — tweak to taste
#define SCROLL_SPEED  60.0
#define MIN_T         350.0

// Set to 1 to mimic Dockrey's variant (X/Y swapped, vertical scroll)
#define MIMIC_DOCKREY 0

// Set to 1 to only glitch 25% of pixels (mask with &3 instead of &1)
#define GLITCH_25     1

void main()
{
    // Pixel coordinates (integer)
    ivec2 res = ivec2(uTDOutputInfo.res.zw);
    ivec2 px  = ivec2(vUV.st * vec2(res));

    // Scrolling offset — decrements over time like the Python version
    int t = int(MIN_T) - int(uTime * SCROLL_SPEED);

    int x = px.x;
    int y = px.y;

    // The core Knuth bitwise fractal formula:
    //   (((l ^ ~r) & ((offset - t) >> 3))**2 >> 12) & mask
    //
    // Python original:
    //   bit = ((((np.bitwise_xor.outer(l, r) & (o - t) >> 3))**2 >> 12) & m) == 1

    int l, r, offset;

#if MIMIC_DOCKREY
    // Dockrey variant: X/Y swapped, scrolls vertically
    l = y;
    r = ~x;
    offset = y;
#else
    // Original orientation
    l = x;
    r = ~y;
    offset = y;
#endif

    int v = (l ^ r) & ((offset - t) >> 3);
    int sq = v * v;
    int result = (sq >> 12);

#if GLITCH_25
    int mask = 3;
#else
    int mask = 1;
#endif

    int bit = result & mask;

    // Output: bit == 1 → black, bit == 0 → white (matching Python's ~mask behavior)
    float c = (bit == 0) ? 1.0 : 0.0;

    fragColor = TDOutputSwizzle(vec4(c, c, c, 1.0));
}

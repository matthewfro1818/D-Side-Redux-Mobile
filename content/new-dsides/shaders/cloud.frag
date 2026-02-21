#pragma header

uniform float iTime;

#define iChannel0 bitmap
#define texture flixel_texture2D

uniform float red_amt;
uniform float green_amt;
uniform float blue_amt;

#define HASHSCALE1 0.1031
#define NUM_CELLS 16.0

float hash12(vec2 p) 
{
    vec3 p3  = fract(vec3(p.xyx) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float valueNoise(vec2 p) 
{
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f); 
    
    float a = hash12(i);
    float b = hash12(i + vec2(1.0, 0.0));
    float c = hash12(i + vec2(0.0, 1.0));
    float d = hash12(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float worley2d(vec2 coord) 
{
    vec2 p = coord * NUM_CELLS;
    vec2 i = floor(p);
    vec2 f = fract(p);
    float minDist = 1.0;
    
    for (int y = 0; y <= 2; y++) 
    { 
        for (int x = 0; x <= 2; x++) 
        {
            vec2 neighbor = vec2(float(x) - 1.0, float(y) - 1.0);
            vec2 cell_id = i + neighbor;
            
            vec2 pointOffset = vec2(hash12(cell_id), hash12(cell_id.yx));
            vec2 diff = neighbor + pointOffset - f;
            minDist = min(minDist, length(diff));
        }
    }
    return clamp(1.0 - (minDist / 1.4142), 0.0, 1.0); 
}

float fbmWorld(vec2 p) 
{
    float sum = 0.0;
    float freq = 2.0; 
    float amp = 0.6;  
    
    for (int i = 0; i < 2; ++i) 
    { 
        sum += worley2d(p * freq) * amp; 
        freq *= 2.0; 
        amp *= 0.6; 
    } 
    return sum; 
}

float fbmPerly(vec2 p) 
{
    float sum = 0.0; 
    float freq = 8.0;   
    float amp = 0.512;  
    
    for (int i = 0; i < 5; ++i) 
    { 
        sum += valueNoise(p * freq) * amp; 
        freq *= 2.0; 
        amp *= 0.8; 
    } 
    return sum; 
}

float remap(float x, float lo1, float hi1, float lo2, float hi2) 
{
    return lo2 + (x - lo1) / (hi1 - lo1) * (hi2 - lo2);
}

void main() 
{
    vec2 uv = openfl_TextureCoordv;
    uv.y *= (openfl_TextureSize.y / openfl_TextureSize.x);
    
    float base = fbmWorld(uv * 0.2 + vec2(iTime * 0.005));
    float detail = 0.3 + 0.2 * fbmPerly(uv * 10.0 + vec2(iTime * 0.01, 0.0));
    
    float noiseValue = remap(detail, 1.0 - base, 1.0, 0.0, 1.0) * 2.0;

    gl_FragColor = vec4(noiseValue * red_amt, noiseValue * green_amt, noiseValue * blue_amt, flixel_texture2D(bitmap, openfl_TextureCoordv).a);
}
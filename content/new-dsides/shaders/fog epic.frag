#pragma header

precision mediump float;

uniform float iTime;
uniform float cloudDensity;
uniform float noisiness;
uniform float speed;
uniform float cloudHeight;

uniform float customred;
uniform float customgreen;
uniform float customblue;

float hash(vec3 p) 
{
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise3D(vec3 x) 
{
    vec3 i = floor(x);
    vec3 f = fract(x);
    
    /* Interpolacao suave */
    f = f * f * (3.0 - 2.0 * f);

    return mix(mix(mix( hash(i + vec3(0,0,0)), 
                        hash(i + vec3(1,0,0)), f.x),
                   mix( hash(i + vec3(0,1,0)), 
                        hash(i + vec3(1,1,0)), f.x), f.y),
               mix(mix( hash(i + vec3(0,0,1)), 
                        hash(i + vec3(1,0,1)), f.x),
                   mix( hash(i + vec3(0,1,1)), 
                        hash(i + vec3(1,1,1)), f.x), f.y), f.z) * 2.0 - 1.0;
}

float fBm(vec3 uv) 
{
    float sum = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    
    for (int i = 0; i < 4; ++i) 
    {
        sum += noise3D(uv * freq) * amp;
        freq *= 2.0;
        amp *= 0.5;
    }
    return sum;
}

float gradient(vec2 uv) 
{
    return (1.0 - uv.y * uv.y * cloudHeight);
}

void main() 
{
    vec2 uv = openfl_TextureCoordv;
    vec3 p = vec3(uv, iTime * speed);
    vec3 offset = vec3(0.1, 0.3, 0.2);
    
    vec2 duv = vec2(fBm(p), fBm(p + offset)) * noisiness;
    
    float q = gradient(uv + duv) * cloudDensity;
    
    q *= 0.65; 
    
    float alpha = flixel_texture2D(bitmap, openfl_TextureCoordv).a;
    
    gl_FragColor = vec4(q - customred, q - customgreen, q - customblue, alpha);
}

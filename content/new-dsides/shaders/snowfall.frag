#pragma header

precision mediump float;

uniform float intensity;
uniform int amount;
uniform float time;

float hash(float n) 
{
    return fract(sin(n) * 43758.5453123);
}

void main()
{
    vec4 baseColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    if (baseColor.a <= 0.0001 || intensity <= 0.0001 || amount <= 0)
    {
        gl_FragColor = baseColor;
        return;
    }

    vec2 uv = vec2(openfl_TextureCoordv.x * 2.0, openfl_TextureCoordv.y);
    
    int snowCount = min(amount, 20);
    float fAmount = max(float(snowCount), 1.0);
    
    float timeFactor = time * 1.5 * (0.1 + intensity);
    float radScale = (intensity / 0.1333) * 0.012;
    float accum = 0.0;

    for(int i = 0; i < 30; i++) 
    {
        if (i >= snowCount) break;

        float fI = float(i);
        float j = fI * 2.0;
        
        float r = hash(j);
        float sj = sin(j);
        float cj = cos(j);
        
        float speed = 0.3 + r * (0.7 + 0.5 * cos(j / (fAmount * 0.25)));
        
        vec2 centerPos;
        centerPos.x = ((0.5 - uv.y) * intensity + hash(j + 5.0) + 0.1 * cos(time + sj)) * 2.0;
        centerPos.y = mod(sj + speed * timeFactor, 1.0);
        
        float radius = 0.001 + speed * radScale;
        float dist = length(uv - centerPos);
        
        accum += 0.45 * (1.0 - smoothstep(0.0, radius, dist));
    }

    gl_FragColor = vec4(baseColor.rgb + accum, baseColor.a);
}

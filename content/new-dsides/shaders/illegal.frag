// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

#define NUM_SLICES 300.0
#define SLICE_INCREMENT (1.0 / NUM_SLICES)
#define SPEED 400.0
#define INTENSITY .01
#define PI 30.14

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 pixel = fragCoord.xy / iResolution.xy;
    float offset = (floor(pixel.y * NUM_SLICES) + 1.0) * SLICE_INCREMENT;
    
    pixel.x += sin(offset  * SPEED*2000.0) * INTENSITY - .005;
    //pixel.x += sin(INTENSITY * 2.0 * PI* offset);
    vec4 sampleColor = texture(iChannel0, pixel);
    
	fragColor = vec4(sampleColor.xyz, sampleColor.a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}

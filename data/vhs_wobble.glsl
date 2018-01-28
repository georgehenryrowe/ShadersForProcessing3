// from shaderToy: https://www.shadertoy.com/view/Ms3XWH

uniform vec2 iResolution;
uniform sampler2D texture;
uniform float iGlobalTime;

#define iChannel0 texture
#define iChannel1 texture

void mainImage( out vec4 fragColor, in vec2 fragCoord );

void main() {
    mainImage(gl_FragColor,gl_FragCoord.xy);
}

const float range = 0.05;
const float noiseQuality = 250.0;
const float noiseIntensity = 0.0044;
const float offsetIntensity = 0.01;
const float colorOffsetIntensity = 0.5;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float verticalBar(float pos, float uvY, float offset) {
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = smoothstep(edge0, pos, uvY) * offset;
    x -= smoothstep(pos, edge1, uvY) * offset;
    return x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;

    for (float i = 0.0; i < 0.71; i += 0.1313) {
        float d = mod(iGlobalTime * i, 1.7);
        float o = sin(1.0 - tan(iGlobalTime * 0.24 * i));
    	o *= offsetIntensity;
        uv.x += verticalBar(d, uv.y, o);
    }

    float uvY = uv.y;
    uvY *= noiseQuality;
    uvY = float(int(uvY)) * (1.0 / noiseQuality);
    float noise = rand(vec2(iGlobalTime * 0.00001, uvY));
    uv.x += noise * noiseIntensity;

    vec2 offsetR = vec2(0.006 * sin(iGlobalTime), 0.0) * colorOffsetIntensity;
    vec2 offsetG = vec2(0.0073 * (cos(iGlobalTime * 0.97)), 0.0) * colorOffsetIntensity;

    float r = texture(iChannel0, uv + offsetR).r;
    float g = texture(iChannel0, uv + offsetG).g;
    float b = texture(iChannel0, uv).b;

    vec4 tex = vec4(r, g, b, 1.0);
    fragColor = tex;
}
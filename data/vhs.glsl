// from shadertoy https://www.shadertoy.com/view/4dBGzK

uniform vec2 iResolution;
uniform sampler2D texture;
uniform float iGlobalTime;

#define iChannel0 texture

highp float rand(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord );

void main() {
    mainImage(gl_FragColor,gl_FragCoord.xy);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	// Flip Y Axis
	// uv.y = -uv.y;

	highp float magnitude = 0.005;


	// Set up offset
	vec2 offsetRedUV = uv;
	offsetRedUV.x = uv.x + rand(vec2(iGlobalTime*0.03,uv.y*0.42)) * 0.001;
	offsetRedUV.x += sin(rand(vec2(iGlobalTime*0.2, uv.y)))*magnitude;

	vec2 offsetGreenUV = uv;
	offsetGreenUV.x = uv.x + rand(vec2(iGlobalTime*0.004,uv.y*0.002)) * 0.004;
	offsetGreenUV.x += sin(iGlobalTime*9.0)*magnitude;

	vec2 offsetBlueUV = uv;
	offsetBlueUV.x = uv.y;
	offsetBlueUV.x += rand(vec2(cos(iGlobalTime*0.01),sin(uv.y)));

	// Load Texture
	float r = texture(iChannel0, offsetRedUV).r;
	float g = texture(iChannel0, offsetGreenUV).g;
	float b = texture(iChannel0, uv).b;

	fragColor = vec4(r,g,b,0);

}
// Bitmap to ASCII (not really) fragment shader by movAX13h, September 2013
// This is the original shader that is now used in PixiJs ans various other products.

// Here's a little tool for new characters: thrill-project.com/archiv/coding/bitmap/

// from ShaderToy https://www.shadertoy.com/view/lssGDj

uniform vec2 iResolution;
uniform sampler2D texture;

#define iChannel0 texture

void mainImage( out vec4 fragColor, in vec2 fragCoord );

void main() {
    mainImage(gl_FragColor,gl_FragCoord.xy);
}

float character(float n, vec2 p)
{
	p = floor(p*vec2(4.0, -4.0) + 2.5);
	if (clamp(p.x, 0.0, 4.0) == p.x && clamp(p.y, 0.0, 4.0) == p.y)
	{
		if (int(mod(n/exp2(p.x + 5.0*p.y), 2.0)) == 1) return 1.0;
	}
	return 0.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy;
	vec3 col = texture(iChannel0, floor(uv/8.0)*8.0/iResolution.xy).rgb;

	float gray = 0.3 * col.r + 0.59 * col.g + 0.11 * col.b;

	float n =  4096.0;             // .
	if (gray > 0.2) n = 65600.0;    // :
	if (gray > 0.3) n = 332772.0;   // *
	if (gray > 0.4) n = 15255086.0; // o
	if (gray > 0.5) n = 23385164.0; // &
	if (gray > 0.6) n = 15252014.0; // 8
	if (gray > 0.7) n = 13199452.0; // @
	if (gray > 0.8) n = 11512810.0; // #

	vec2 p = mod(uv/4.0, 2.0) - vec2(1.0);
	// if (iMouse.z > 0.5)	col = gray*vec3(character(n, p));
	col = col*character(n, p);

	fragColor = vec4(col, 1.0);
}
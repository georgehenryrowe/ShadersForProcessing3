// from ShaderToy: https://www.shadertoy.com/view/MlBSzR

uniform vec2 iResolution;
uniform sampler2D texture;
uniform float iGlobalTime;

#define iChannel0 texture
#define iChannel1 texture

void mainImage( out vec4 fragColor, in vec2 fragCoord );

void main() {
    mainImage(gl_FragColor,gl_FragCoord.xy);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
//    uv.t = 1.0 - uv.t;

    float x = uv.s;
    float y = uv.t;

    //
    float glitchStrength = 800/iResolution.y * 5.0;

    // get snapped position
    float psize = 0.04 * glitchStrength;
    float psq = 1.0 / psize;

    float px = floor( x * psq + 0.5) * psize;
    float py = floor( y * psq + 0.5) * psize;

	vec4 colSnap = texture( iChannel0, vec2( px,py) );

	float lum = pow( 1.0 - (colSnap.r + colSnap.g + colSnap.b) / 3.0, glitchStrength ); // remove the minus one if you want to invert luma

    // do move with lum as multiplying factor
    float qsize = psize * lum;

    float qsq = 1.0 / qsize;

    float qx = floor( x * qsq + 0.5) * qsize;
    float qy = floor( y * qsq + 0.5) * qsize;

    float rx = (px - qx) * lum + x;
    float ry = (py - qy) * lum + y;

	vec4 colMove = texture( iChannel0, vec2( rx,ry) );


    // final color
    fragColor = colMove;
}

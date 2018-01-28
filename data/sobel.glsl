// from shadertoy https://www.shadertoy.com/view/ldsSWr

// Basic edge detection via convolution
// Ken Slade - ken.slade@gmail.com
// at https://www.shadertoy.com/view/ldsSWr

// Based on original Sobel shader by:
// Jeroen Baert - jeroen.baert@cs.kuleuven.be (www.forceflow.be)
// at https://www.shadertoy.com/view/Xdf3Rf

uniform vec2 iResolution;
uniform sampler2D texture;
uniform float iGlobalTime;

#define iChannel0 texture
#define iChannel1 texture
#define iChannel2 texture

void mainImage( out vec4 fragColor, in vec2 fragCoord );

void main() {
    mainImage(gl_FragColor,gl_FragCoord.xy);
}

//options are edge, colorEdge, or trueColorEdge
#define EDGE_FUNC trueColorEdge

//options are KAYYALI_NESW, KAYYALI_SENW, PREWITT, ROBERTSCROSS, SCHARR, or SOBEL
#define SOBEL

// Use these parameters to fiddle with settings
#ifdef SCHARR
#define STEP 0.15
#else
#define STEP 1.0
#endif


#ifdef KAYYALI_NESW
const mat3 kayyali_NESW = mat3(-6.0, 0.0, 6.0,
							   0.0, 0.0, 0.0,
							   6.0, 0.0, -6.0);
#endif
#ifdef KAYYALI_SENW
const mat3 kayyali_SENW = mat3(6.0, 0.0, -6.0,
							   0.0, 0.0, 0.0,
							   -6.0, 0.0, 6.0);
#endif
#ifdef PREWITT
// Prewitt masks (see http://en.wikipedia.org/wiki/Prewitt_operator)
const mat3 prewittKernelX = mat3(-1.0, 0.0, 1.0,
								 -1.0, 0.0, 1.0,
								 -1.0, 0.0, 1.0);

const mat3 prewittKernelY = mat3(1.0, 1.0, 1.0,
								 0.0, 0.0, 0.0,
								 -1.0, -1.0, -1.0);
#endif
#ifdef ROBERTSCROSS
// Roberts Cross masks (see http://en.wikipedia.org/wiki/Roberts_cross)
const mat3 robertsCrossKernelX = mat3(1.0, 0.0, 0.0,
									  0.0, -1.0, 0.0,
									  0.0, 0.0, 0.0);
const mat3 robertsCrossKernelY = mat3(0.0, 1.0, 0.0,
									  -1.0, 0.0, 0.0,
									  0.0, 0.0, 0.0);
#endif
#ifdef SCHARR
// Scharr masks (see http://en.wikipedia.org/wiki/Sobel_operator#Alternative_operators)
const mat3 scharrKernelX = mat3(3.0, 10.0, 3.0,
								0.0, 0.0, 0.0,
								-3.0, -10.0, -3.0);

const mat3 scharrKernelY = mat3(3.0, 0.0, -3.0,
								10.0, 0.0, -10.0,
								3.0, 0.0, -3.0);
#endif
#ifdef SOBEL
// Sobel masks (see http://en.wikipedia.org/wiki/Sobel_operator)
const mat3 sobelKernelX = mat3(1.0, 0.0, -1.0,
							   2.0, 0.0, -2.0,
							   1.0, 0.0, -1.0);

const mat3 sobelKernelY = mat3(-1.0, -2.0, -1.0,
							   0.0, 0.0, 0.0,
							   1.0, 2.0, 1.0);
#endif

//performs a convolution on an image with the given kernel
float convolve(mat3 kernel, mat3 image) {
	float result = 0.0;
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			result += kernel[i][j]*image[i][j];
		}
	}
	return result;
}

//helper function for colorEdge()
float convolveComponent(mat3 kernelX, mat3 kernelY, mat3 image) {
	vec2 result;
	result.x = convolve(kernelX, image);
	result.y = convolve(kernelY, image);
	return clamp(length(result), 0.0, 255.0);
}

//returns color edges using the separated color components for the measure of intensity
//for each color component instead of using the same intensity for all three.  This results
//in false color edges when transitioning from one color to another, but true colors when
//the transition is from black to color (or color to black).
vec4 colorEdge(float stepx, float stepy, vec2 center, mat3 kernelX, mat3 kernelY) {
	//get samples around pixel
	vec4 colors[9];
	colors[0] = texture(iChannel0,center + vec2(-stepx,stepy));
	colors[1] = texture(iChannel0,center + vec2(0,stepy));
	colors[2] = texture(iChannel0,center + vec2(stepx,stepy));
	colors[3] = texture(iChannel0,center + vec2(-stepx,0));
	colors[4] = texture(iChannel0,center);
	colors[5] = texture(iChannel0,center + vec2(stepx,0));
	colors[6] = texture(iChannel0,center + vec2(-stepx,-stepy));
	colors[7] = texture(iChannel0,center + vec2(0,-stepy));
	colors[8] = texture(iChannel0,center + vec2(stepx,-stepy));

	mat3 imageR, imageG, imageB, imageA;
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			imageR[i][j] = colors[i*3+j].r;
			imageG[i][j] = colors[i*3+j].g;
			imageB[i][j] = colors[i*3+j].b;
			imageA[i][j] = colors[i*3+j].a;
		}
	}

	vec4 color;
	color.r = convolveComponent(kernelX, kernelY, imageR);
	color.g = convolveComponent(kernelX, kernelY, imageG);
	color.b = convolveComponent(kernelX, kernelY, imageB);
	color.a = convolveComponent(kernelX, kernelY, imageA);

	return color;
}

//finds edges where fragment intensity changes from a higher value to a lower one (or
//vice versa).
vec4 edge(float stepx, float stepy, vec2 center, mat3 kernelX, mat3 kernelY){
	// get samples around pixel
	mat3 image = mat3(length(texture(iChannel0,center + vec2(-stepx,stepy)).rgb),
					  length(texture(iChannel0,center + vec2(0,stepy)).rgb),
					  length(texture(iChannel0,center + vec2(stepx,stepy)).rgb),
					  length(texture(iChannel0,center + vec2(-stepx,0)).rgb),
					  length(texture(iChannel0,center).rgb),
					  length(texture(iChannel0,center + vec2(stepx,0)).rgb),
					  length(texture(iChannel0,center + vec2(-stepx,-stepy)).rgb),
					  length(texture(iChannel0,center + vec2(0,-stepy)).rgb),
					  length(texture(iChannel0,center + vec2(stepx,-stepy)).rgb));
 	vec2 result;
	result.x = convolve(kernelX, image);
	result.y = convolve(kernelY, image);

    float color = clamp(length(result), 0.0, 255.0);
    return vec4(color);
}

//Colors edges using the actual color for the fragment at this location
vec4 trueColorEdge(float stepx, float stepy, vec2 center, mat3 kernelX, mat3 kernelY) {
	vec4 edgeVal = edge(stepx, stepy, center, kernelX, kernelY);
	return edgeVal * texture(iChannel0,center);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec4 color = texture(iChannel0, uv.xy);
#ifdef KAYYALI_NESW
	fragColor = EDGE_FUNC(STEP/iResolution[0], STEP/iResolution[1],
							uv,
							kayyali_NESW, kayyali_NESW);
#endif
#ifdef KAYYALI_SENW
	fragColor = EDGE_FUNC(STEP/iResolution[0], STEP/iResolution[1],
							uv,
							kayyali_SENW, kayyali_SENW);
#endif
#ifdef PREWITT
	fragColor = EDGE_FUNC(STEP/iResolution[0], STEP/iResolution[1],
							uv,
							prewittKernelX, prewittKernelY);
#endif
#ifdef ROBERTSCROSS
	fragColor = EDGE_FUNC(STEP/iResolution[0], STEP/iResolution[1],
							uv,
							robertsCrossKernelX, robertsCrossKernelY);
#endif
#ifdef SOBEL
	fragColor = EDGE_FUNC(STEP/iResolution[0], STEP/iResolution[1],
							uv,
							sobelKernelX, sobelKernelY);
#endif
#ifdef SCHARR
	fragColor = EDGE_FUNC(STEP/iResolution[0], STEP/iResolution[1],
							uv,
							scharrKernelX, scharrKernelY);
#endif
}
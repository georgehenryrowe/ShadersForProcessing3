// from shaderToy https://www.shadertoy.com/view/XtsSzr

// Created by fatumR
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

uniform vec2 iResolution;
uniform sampler2D texture;
uniform float iGlobalTime;

#define iChannel0 texture

void mainImage( out vec4 fragColor, in vec2 fragCoord );

void main() {
    mainImage(gl_FragColor,gl_FragCoord.xy);
}

// Color conversion related functions
vec3 rgb2hsv(vec3 color) {
    vec3 HSV = vec3(0.); // x -> H, y -> S, z -> V
    float Max = max(color.r, max(color.g, color.b));
    float Min = min(color.r, min(color.g, color.b));
    float chroma = Max - Min;
    
    HSV.z = Max;
    
    if (chroma > 0.) {
        vec3 components = vec3(0.);
        if (Max == color.r) {
            components.xy = color.gb;
        } else if (Max == color.g) {
            components.xy = color.br;
            components.z = 2.;
        } else {
            components.xy = color.rg;
            components.z = 4.;
        }
        
        HSV.x = fract(((components.x - components.y)/chroma + components.z) / 6.);

        // Saturation
        if (Max > 0.) {
        	HSV.y = chroma / Max;
        } else {
            HSV.y = 0.;
        }
    }
    
    return HSV;
}

vec3 hsv2rgb( in vec3 c )
{
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );

	return c.z * mix( vec3(1.0), rgb, c.y);
}

// Blur generation related functions
vec4 boxBlur(vec2 uv, float scale) {
    // Simple box blurring
    const int numSteps = 15;
    
    uv = ((uv * 2. - 1.) *scale) * .5 + .5;
    
    vec4 acc = texture(iChannel0, uv);
    vec2 stepI = 1./iResolution.xy;
    stepI *= scale;
    vec2 offsetU = vec2(0.0);
    vec2 offsetD = vec2(0.0);
    
    for (int j = 0; j < numSteps; j++) {
        offsetU.y += stepI.y;
        offsetU.x = 0.;
        for (int i = 0; i < numSteps; i++) {
            acc += pow(texture(iChannel0, uv + offsetU), vec4(2.2));
            acc += pow(texture(iChannel0, uv - offsetU), vec4(2.2));
            offsetU.x += stepI.x;
        }
    
        offsetD.y -= stepI.y;
        offsetD.x = 0.;
        for (int i = 0; i < numSteps; i++) {
            acc += pow(texture(iChannel0, uv + offsetD), vec4(2.2));
            acc += pow(texture(iChannel0, uv - offsetD), vec4(2.2));
            offsetD.x += stepI.x;
        }
    }
    
    // Gamma correction is added, as it's done by iq here: https://www.shadertoy.com/view/XtsSzH
    return pow(acc / (float(numSteps * numSteps * 4) + 1.), vec4(1. / 2.2));
    
}

// Kind of Guass blur approximation
vec4 gaussBlurApprox(vec2 uv, float scale) {
    const int numSteps = 15;
    // Strange but const declaration gets an error, 
    // but there is an official way to declare const arrays.
    float gaussCoeff[15]; // 1D gauss kernel, normalized
    gaussCoeff[0] = 0.053917;
    gaussCoeff[1] = 0.053551;
    gaussCoeff[2] = 0.052469;
    gaussCoeff[3] = 0.050713;
    gaussCoeff[4] = 0.048354;
    gaussCoeff[5] = 0.045481;
    gaussCoeff[6] = 0.042201;
    gaussCoeff[7] = 0.038628;
    gaussCoeff[8] = 0.034879;
    gaussCoeff[9] = 0.031068;
    gaussCoeff[10] = 0.027300;
    gaussCoeff[11] = 0.023664;
    gaussCoeff[12] = 0.020235;
    gaussCoeff[13] = 0.017070;
    gaussCoeff[14] = 0.014204;
   
    uv = ((uv * 2. - 1.) *scale) * .5 + .5; // central scaling
    
    vec4 acc = texture(iChannel0, uv) * gaussCoeff[0];
    vec2 stepI = 1./iResolution.xy;
    stepI *= scale;
    vec2 offsetU = vec2(0.0);
    vec2 offsetD = vec2(0.0);
    
    for (int j = 0; j < numSteps; j++) {
        offsetU.y += stepI.y;
        offsetU.x = 0.;
        for (int i = 0; i < numSteps; i++) {
            acc += pow(texture(iChannel0, uv + offsetU), vec4(2.2)) * gaussCoeff[1 + i] * gaussCoeff[1 + j];
            acc += pow(texture(iChannel0, uv - offsetU), vec4(2.2)) * gaussCoeff[1 + i] * gaussCoeff[1 + j];
            offsetU.x += stepI.x;
        }
   
        offsetD.y -= stepI.y;
        offsetD.x = 0.;
        for (int i = 0; i < numSteps; i++) {
            acc += pow(texture(iChannel0, uv + offsetD), vec4(2.2)) * gaussCoeff[1 + i] * gaussCoeff[1 + j];
            acc += pow(texture(iChannel0, uv - offsetD), vec4(2.2)) * gaussCoeff[1 + i] * gaussCoeff[1 + j];
            offsetD.x += stepI.x;
        }
    }
    // Gamma correction is added, as it's done by iq here: https://www.shadertoy.com/view/XtsSzH
    return pow(acc, 1. / vec4(2.2));
    
}

// Edge detection related functions
vec4 detectEdgesSimple(vec2 uv) {
    // Simple central diff detector
    vec4 offset = vec4(1./iResolution.xy, -1./iResolution.xy);
    vec4 hill = texture(iChannel0, uv);
    
    vec4 acc = (hill - texture(iChannel0, uv + offset.x)) / offset.x;
    acc += (hill - texture(iChannel0, uv - offset.x)) / offset.x;
    acc += (hill - texture(iChannel0, uv + offset.y)) / offset.y;
    acc += (hill - texture(iChannel0, uv - offset.y)) / offset.y;
    acc += (hill - texture(iChannel0, uv + offset.xy)) / (.5 * (offset.x + offset.y));
    acc += (hill - texture(iChannel0, uv - offset.xy)) / (.5 * (offset.x + offset.y));
    acc += (hill - texture(iChannel0, uv + offset.zy)) / (.5 * (offset.x + offset.y));
	acc += (hill - texture(iChannel0, uv - offset.xw)) / (.5 * (offset.x + offset.y));

	return abs(acc * .003); // Changing the multiplier we can control the number o edges
}

float detectEdgesSobel(vec2 uv) {
    // Edge detection based on Sobel kernel
    vec4 offset = vec4(1./iResolution.xy, -1./iResolution.xy);
    
    float gx = 0.0;
    float gy = 0.0;
    
    vec4 clr = texture(iChannel0, uv - offset.xy);
    gx += -1. * dot(clr, clr);
    gy += -1. * dot(clr, clr);
    
    clr = texture(iChannel0, uv - offset.x);
    gx += -2. * dot(clr, clr);
    
    clr = texture(iChannel0, uv + offset.zy);
    gx += -1. * dot(clr, clr);
    gy +=  1. * dot(clr, clr);
    
    clr = texture(iChannel0, uv + offset.xw);
    gx +=  1. * dot(clr, clr);
    gy += -1. * dot(clr, clr);
    
    clr = texture(iChannel0, uv + offset.x);
    gx += 2. * dot(clr, clr);
    
    clr = texture(iChannel0, uv + offset.xy);
    gx += 1. * dot(clr, clr);
    gy += 1. * dot(clr, clr);
    
    clr = texture(iChannel0, uv - offset.y);
    gy += -2. * dot(clr, clr);
    
    clr = texture(iChannel0, uv + offset.y);
    gy += 2. * dot(clr, clr);
    
	return gx*gx + gy*gy;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    int effectType = int(mod(floor(iGlobalTime / 34.), 4.));

    vec3 blurredClr;
    float edge;
    if (effectType == 0 || effectType == 2) {
        blurredClr = clamp(gaussBlurApprox(uv, 1.), 0., 1.).rgb;
        edge = detectEdgesSobel(uv);
    } else if (effectType == 1 || effectType == 3) {
        blurredClr = clamp(boxBlur(uv, 1.), 0., 1.).rgb;
        edge = length(detectEdgesSimple(uv));
    }
    vec3 origClr = texture(iChannel0, uv, 0.).rgb;
    vec3 hsv = rgb2hsv(origClr.rgb);
    hsv.y = min(hsv.y * 2., 1.);
    hsv.z = min(hsv.z * 1.75, 1.);
    
    vec3 rgb;
    if (effectType == 2 || effectType == 3) {
    	rgb = hsv2rgb(hsv) * 0.5;
    } else {
        rgb = hsv2rgb(hsv);
    }
    origClr = mix(blurredClr, rgb, clamp(edge, 0., 1.));
    
	fragColor = vec4(origClr,1.0);
}
//ALL SHADERS ARE FROM SHADERTOY AND CONVERTED FOR PROCESSING
//VIDEO IS FROM PEXELS VIDEO
//THANKS TO EVERYONE FOR SHARING

//YOU NEED THE PROCESSING VIDEO LIBRARY TO PLAY THE VIDEO
import processing.video.*;

Movie        videoComp;
PShader      vhs, vhs_glitch, vhs_wobble, binaryGlitch, sobel, ascii, bloom;

int          filterState         = 0;
int          numberOfFilters     = 7;
String       currentFilter;

//STUFF
boolean      skip = false;

//**********************************************************************

void setup() {
  size(1280, 720, P3D);
  smooth(16);
  //blendMode(EXCLUSION);
  colorMode(HSB, 360, 100, 100, 100);

  //LOAD IN VIDEO
  videoComp = new Movie(this, "wetCity.mp4");
  videoComp.loop();

  //LOAD IN SHADERS
  vhs = loadShader("vhs.glsl");
  vhs.set("iResolution", float(width), float(height));
  vhs_glitch = loadShader("vhs_glitch.glsl");
  vhs_glitch.set("iResolution", float(width), float(height));
  vhs_wobble = loadShader("vhs_wobble.glsl");
  vhs_wobble.set("iResolution", float(width), float(height));
  binaryGlitch = loadShader("binaryGlitch.glsl");
  binaryGlitch.set("iResolution", float(width), float(height));
  sobel = loadShader("sobel.glsl");
  sobel.set("iResolution", float(width), float(height));
  ascii = loadShader("ascii.glsl");
  ascii.set("iResolution", float(width), float(height));
  bloom = loadShader("bloomHDR.glsl");
  bloom.set("iResolution", float(width), float(height));
}

//**********************************************************************

void draw() {

  //NEXT FILTER EVERY TIME YOU PRESS A
  if (skip == true) {
    filterState++;
    if (filterState > numberOfFilters) {
      filterState = 0;
    }
    skip         = false;
  }

  //SHADER SETTINGS
  vhs.set("iGlobalTime", millis() / 1000.0);
  vhs_glitch.set("iGlobalTime", millis() / 1000.0);
  vhs_wobble.set("iGlobalTime", millis() / 1000.0);
  bloom.set("iGlobalTime", millis() / 1000.0);

  //DRAW THE LAYERS
  image(videoComp, 0, 0, width, height);
  filterLayer();

  //READOUT
  surface.setTitle("FPS " + nf(int(frameRate), 2) + " || filterState " + currentFilter);
}

void movieEvent(Movie m) {
  m.read();
}
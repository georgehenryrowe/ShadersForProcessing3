void filterLayer() {
  switch(filterState) {
  case 0:
    filter(vhs);
    currentFilter = "vhs";
    break;
  case 1:
    filter(vhs_glitch);
    currentFilter = "vhs_glitch";
    break;
  case 2:
    filter(vhs_wobble);
    currentFilter = "vhs_wobble";
    break;
  case 3:
    filter(binaryGlitch);
    currentFilter = "binaryGlitch";
    break;
  case 4:
    filter(sobel);
    currentFilter = "sobel";
    break;
  case 5:
    filter(ascii);
    currentFilter = "ascii";
    break;
  case 6:
    filter(bloom);
    currentFilter = "bloom";
    break;
  case 7:
    currentFilter = "none";
    break;
  }
}

import processing.sound.*;
import soundtrack.optical.*;

// Export video to image sequence using ffmpeg 
// ffmpeg -i video.mov -f image2 -r 24 /tmp/image-%04d.png
// ffmpeg -i video.mov -acodec pcm_s16le -ac 1 audio.wav //-ar 16000 sets rate

/**
 *  CHANGE THESE
 **/

String DESKTOP = System.getProperty("user.home") + "/Desktop";
String SOURCE = DESKTOP + "/frames/";           //path to directory containing frames
String SOUND = DESKTOP + "/audio/audio.wav";    //leave empty string if silent
String RENDER_PATH = DESKTOP + "/";             //path to directory where pages will be placed

//types: unilateral, variable area, dual variable area, maurer, variable density
String SOUNDTRACK_TYPE = "unilateral";
int DPI = 1440;               //maximum printer DPI 
String PITCH = "long";        // long, short //7.62, 7.605
String FORMAT = "16mm";       //16mm or super16
int PERFS = 1;                //single (1) or double (2) perf film
float PAGE_W = 8.5;           //page width in inches
float PAGE_H = 11.0;          //page height in inches
float SAFE_W = .25;           //safe area on each side of the page
float SAFE_H = .5;            //safe area on top and bottom of page
color BACKGROUND = color(0);  //the color that will fill the entire frame where there's no image
boolean NEGATIVE = false;     //true to invert image data
boolean SHOW_PERFS = true;    //set to true to print perfs for cutting registration
color PERFS_COLOR = color(255);
int SOUND_OFFSET = 25;

//This is a magic number that is used to scale the vertical (H) or horizontal (W) resolution
//because the printer sometimes lies to you.
float MAGIC_H_CORRECTION = 251.45999 / 253.4; //1.0;
float MAGIC_W_CORRECTION = 1.0;

/**
 * CONSTANTS (DON'T CHANGE PLZ)
 **/
float IN = 25.4;
float LONG_H = 7.62;
float SHORT_H = 7.605;     
float STD16_W = 10.26;   //0.413"
float STD16_H = 7.49;    //0.295"
float SUPER16_W = 12.52; //0.492" 
float SUPER16_H = 7.41;  //0.292"
float PERF_W = 1.829;
float PERF_H = 1.27;
float DPMM = DPI / IN;

int SPACING = PITCH.equals("long") ? round(LONG_H * DPMM * MAGIC_H_CORRECTION) : round(SHORT_H * DPMM * MAGIC_H_CORRECTION);
int PAGE_W_PIXELS = ceil((PAGE_W - (SAFE_W * 2)) * DPI * MAGIC_W_CORRECTION);
int PAGE_H_PIXELS = ceil((PAGE_H - (SAFE_H * 2)) * DPI * MAGIC_H_CORRECTION);
int FRAME_W = FORMAT.equals("super16") ? round(SUPER16_W * DPMM * MAGIC_W_CORRECTION) : round(STD16_W * DPMM * MAGIC_W_CORRECTION);
int FRAME_H = FORMAT.equals("super16") ? round(SUPER16_H * DPMM * MAGIC_H_CORRECTION) : round(STD16_H * DPMM * MAGIC_H_CORRECTION);
int LEFT_PAD = round(((16 - STD16_W) / 2) * DPMM * MAGIC_W_CORRECTION); //space to left of frame
int COLUMNS = floor(PAGE_W_PIXELS / (16 * DPMM));
int ROWS = floor(PAGE_H_PIXELS / SPACING);
int FRAME_LINE = round((SPACING - FRAME_H) / 2);
int PAGES = 0;
int FRAMES = 0;
int SOUND_W = ceil(DPMM * (12.52 - 10.26));

SoundtrackOptical soundtrack;
String[] frames;
PImage frameBuffer;
PGraphics frameBlank;
PGraphics pageBuffer;
PGraphics soundBuffer;

void setup () {
  size(640, 480);
  //surface.setResizable(true);
  println(SOURCE);
  frames = listFrames(SOURCE);
  if (frames == null) {
    println("Frames not found, check SOURCE path");
    exit();
  }
  
  FRAMES = frames.length;
  PAGES = ceil((float) FRAMES / (ROWS * COLUMNS));
  pageBuffer = createGraphics(PAGE_W_PIXELS, PAGE_H_PIXELS);
  
  if (!SOUND.equals("")) {
    soundtrack = new SoundtrackOptical(this, SOUND, DPI, 1.0, SOUNDTRACK_TYPE, PITCH, !NEGATIVE);
  }
  
  printInfo();
  
  if (PERFS == 2 && !SOUND.equals("") ) {
    println("WARNING: Double perf film and soundtrack will interfere with one another. Are you sure?"); 
  }
  
  if (FORMAT.equals("super16") && !SOUND.equals("")) {
    println("WARNING: Super16 frame and soundtrack will interfere with one another. Are you sure?"); 
  }
  
  if (FORMAT.equals("super16") && PERFS == 2) {
    println("WARNING: Super16 frame and double perf film will interfere with one another. Are you sure?"); 
  }

  text("DISPLAY", 200, 200);
  frameBlank = createGraphics(FRAME_W, FRAME_H);
  noLoop();
  delay(1000);
  thread("renderPages");
}

void draw () {
  background(0);
  fill(255);
  text("SOURCE DIR: " + SOURCE, 10, 20);
  text("DPI: " + DPI, 10, 40);
  text("STRETCH: " + MAGIC_W_CORRECTION + " x " + MAGIC_H_CORRECTION, 10, 60);
  text("FRAMES: " + FRAMES, 10, 80);
  text("FRAME SIZE: " + FRAME_W + "x" + FRAME_H + " px", 10, 100);
  text("PAGES: " + PAGES, 10, 120);
  text("PAGE SIZE: " + PAGE_W_PIXELS + "x" + PAGE_H_PIXELS + " px", 10, 140);
  text("FRAMES/PAGE: " + (ROWS * COLUMNS), 10, 160);
  text("SECONDS/PAGE: " + ((ROWS * COLUMNS) / 24), 10, 180);
}

void printInfo() {
  println("STRETCH: " + MAGIC_W_CORRECTION + " x " + MAGIC_H_CORRECTION);
  println("PAGE SIZE: " + PAGE_W_PIXELS + "x" + PAGE_H_PIXELS);
  println("FRAME SIZE: " + FRAME_W + "x" + FRAME_H);
  println("FRAMES PER STRIP: " + ROWS);
  println("STRIPS PER PAGE: " + COLUMNS);
  println("FRAMES PER PAGE: " + (ROWS * COLUMNS));
  println("SECONDS PER PAGE: " + ((ROWS * COLUMNS) / 24));
  println("FRAMES: " + FRAMES);
  println("PAGES: " + PAGES);
  //println("RENDER_PATH: " + RENDER_PATH);
  if (!SOUND.equals("")) {
    println("SOUNDTRACK SAMPLE RATE: " + (SPACING * 24));
  }
}

String[] listFrames (String dir) {
  ArrayList<String> tmp = new ArrayList<String>();
  String output[];
  File file;
  int arraySize;
  int o = 0;
  if (dir.substring(dir.length() - 1, dir.length()) != "/") {
    dir = dir + "/";
  }
  file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    names = sort(names);
    for (int i = 0; i < names.length; i++) {
      if (names[i].toLowerCase().contains(".jpg") || 
          names[i].toLowerCase().contains(".jpeg") ||
          names[i].toLowerCase().contains(".tif") || //only works with Processing tiffs
          names[i].toLowerCase().contains(".png")) {
        tmp.add(dir + names[i]); 
      }
    }
    
    arraySize = tmp.size();
    
    if (!SOUND.equals("")) {
      arraySize += SOUND_OFFSET;
    }
    
    output = new String[arraySize];
    
    if (!SOUND.equals("")) {
      for (int i = 0; i < SOUND_OFFSET; i++) {
        output[o] = "_BLANK_";
        o++;
      }
    }
    
    for (int i = 0; i < tmp.size(); i++) {
      output[o] = tmp.get(i);
      o++;
    }
    sort(output);
    return output;
  } else {
    return null;
  }
}

String leftPad (int val) {
  String str = "" + val;
  if (str.length() == 1) {
    str = "0" + str;
  }
  return str;
}

void renderPages() {
  //surface.setSize(PAGE_W_PIXELS, PAGE_H_PIXELS / SEGMENTS);
  //delay(1000);
  int cursor;
  int leftX;
  int topY;
  int perfLeft;
  int perfRight;
  int perfTop;
  int soundTop;
  int soundLeft;
  boolean hasFrames = false;
  
  frameBlank.beginDraw();
  frameBlank.background(BACKGROUND);
  frameBlank.endDraw();
  
  
  for (int page = 0; page < PAGES; page++) {
    pageBuffer.beginDraw();
    pageBuffer.textSize(60);
    pageBuffer.clear();
    pageBuffer.background(255);
    pageBuffer.stroke(0);
    pageBuffer.noFill();
    //draw calibration marks to be overwritten if needed
    pageBuffer.rect(0, 0, 10 * DPMM, 10 * DPMM);
    pageBuffer.rect(((16 * COLUMNS) * DPMM) - (10 * DPMM) - 1, 0, 10 * DPMM, 10 * DPMM);
    pageBuffer.rect(((16 * COLUMNS) * DPMM) - (10 * DPMM) - 1, ((ROWS * (SPACING / DPMM)) * DPMM) - (10 * DPMM) - 1, 10 * DPMM, 10 * DPMM);
    pageBuffer.rect(0, ((ROWS * (SPACING / DPMM)) * DPMM) - (10 * DPMM) - 1, 10 * DPMM, 10 * DPMM);
    //pageBuffer.stroke(0);
    for (int x = 0; x < COLUMNS; x++) {
      //pageBuffer.line(x * (16 * DPMM), 0, x * (16 * DPMM), PAGE_H_PIXELS);
      for (int y = 0; y < ROWS; y++) {
        cursor = (page * (COLUMNS * ROWS)) + (x * ROWS) + y; 
        if (cursor >= FRAMES) {
          hasFrames = false;
          break;
        }
        hasFrames = true;
        println("Frame " + cursor + "/" + FRAMES);
        
        topY = (y * SPACING) + FRAME_LINE;
        leftX = x * (round(16 * DPMM)) + LEFT_PAD;
        perfTop = round((y * SPACING) - ((PERF_H / 2) * DPMM));
        
        pageBuffer.noStroke();
        pageBuffer.fill(BACKGROUND);
        pageBuffer.rect(x * (round(16 * DPMM)), (y * SPACING), round(16*DPMM), SPACING);
        
        if (SHOW_PERFS){
          perfLeft = round(x * (round(16 * DPMM)) + (.85 * DPMM));
          pageBuffer.fill(PERFS_COLOR);
          //rect([1.829, 1.27, 2], d = .5, center = true);
          //﻿.85 from side
          pageBuffer.rect(perfLeft, perfTop, PERF_W * DPMM, PERF_H * DPMM, .26 * DPMM);
          
          //last perf
          if (y == ROWS - 1) {
            perfTop = round(((y + 1) * SPACING) - ((PERF_H / 2) * DPMM));
            pageBuffer.rect(perfLeft, perfTop, PERF_W * DPMM, PERF_H * DPMM, .26 * DPMM);
          }
        }
        
        if (SHOW_PERFS && PERFS == 2) {
          perfRight = round((x + 1) * (round(16 * DPMM)) - (PERF_W * DPMM) - (.85 * DPMM));
          pageBuffer.rect(perfRight, perfTop, PERF_W * DPMM, PERF_H * DPMM, .26 * DPMM);
          
          if (y == ROWS - 1) {
            perfTop = round(((y + 1) * SPACING) - ((PERF_H / 2) * DPMM));
            pageBuffer.rect(perfRight, perfTop, PERF_W * DPMM, PERF_H * DPMM, .26 * DPMM);
          }
        }
        
        if (frames[cursor].equals("_BLANK_")) {
          pageBuffer.image(frameBlank, leftX, topY, FRAME_W, FRAME_H);
        } else {
          frameBuffer = loadImage(frames[cursor]);
          if (NEGATIVE) {
            frameBuffer.filter(INVERT);
          }
          frameBuffer.resize(FRAME_W, FRAME_H);
          pageBuffer.image(frameBuffer, leftX, topY, FRAME_W, FRAME_H);
        }
        
        if (!SOUND.equals("")) {
          soundTop = y * SPACING;
          soundLeft = (x * round(16 * DPMM)) + LEFT_PAD + FRAME_W + round(0.3368 * DPMM);
          try {
            soundBuffer = soundtrack.buffer(cursor);
            if (soundBuffer != null) {
              pageBuffer.image(soundBuffer, soundLeft, soundTop, round((12.52 - 10.26 - 0.3368) * DPMM), SPACING);
            }
          } catch (Error e) {
            //
          }
        }
        if (hasFrames) {
          text((x + 1) + "", (x * 16 * DPMM) + (8 * DPMM), ROWS * SPACING + 20);
        }
      }
    }
    pageBuffer.endDraw();
    pageBuffer.save(RENDER_PATH + "page_" + page + ".tif");
    println("Saved page_" + page + ".tif");
  }
  printInfo();
  exit();
}

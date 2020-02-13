int DPI = 1440;
//Change this to a DPI supported by your printer.
//
//Make sure to convert the generated "page_#.tif" files to the set DPI
//and print at 100% scale. By default, Processing will generate a file
//@ 72 DPI which may make the scaling math difficult. Use Preview, Photoshop
//or ImageMagick to convert the file to the DPI you set here.

String PITCH = "long";       // long, short //7.62, 7.605
String FORMAT = "16mm";      //16mm or super16
int PERFS = 1;               //single (1) or double (2) perf film
float PAGE_W = 8.5;          //page width in inches
float PAGE_H = 11.0;         //page height in inches
float SAFE_W = .25;          //safe area on each side of the page
float SAFE_H = .5;           //safe area on top and bottom of page

//Change these to calibrate for printer stretch.
//Use either the total length markings in the bottom left or top right of the page
//to compare the desired length to the actual printed length OR use the
//10cm rulers on either axis to compare the printed length that should be 100mm.
//
//In the case that the printed ruler measures 101.5mm down, change the variable to:
//MAGIC_H_CORRECTION = 100 / 101.5; or desired length / printed length
//
//Once you have this fraction, you can confirm it with a second print of this file 
//or then use it in the filmless_processing.pde sketch.

float MAGIC_H_CORRECTION = 1.0; 
float MAGIC_W_CORRECTION = 1.0;

/** DON'T CHANGE THESE **/

float IN = 25.4;
float LONG_H = 7.62;
float SHORT_H = 7.605;
float STD16_W = 10.26;   //0.413"
float STD16_H = 7.49;    //0.295"
float SUPER16_W = 12.52; //0.492" 
float SUPER16_H = 7.41;  //0.292'
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
int FONT_SIZE = ceil(DPI / 24);

PGraphics page;

void printInfo() {
  println("PAGE SIZE: " + PAGE_W_PIXELS + "x" + PAGE_H_PIXELS);
  println("FRAME SIZE: " + FRAME_W + "x" + FRAME_H);
  println("FRAMES PER STRIP: " + ROWS);
  println("STRIPS PER PAGE: " + COLUMNS);
  println("FRAMES PER PAGE: " + (ROWS * COLUMNS));
  
  println("CALIBRATION W (MM): " + (16 * COLUMNS));
  println("CALIBRATION H (MM): " + (ROWS * (SPACING / DPMM)));
  
  println("SOUNDTRACK SAMPLE RATE: " + (SPACING * 24));
}

void setup () {
  printInfo();
  page = createGraphics(PAGE_W_PIXELS, PAGE_H_PIXELS);
  page.beginDraw();
  page.background(255);
  page.stroke(0);
  page.fill(0);
  page.textSize(FONT_SIZE);
  float leftX = 20 * DPMM * MAGIC_W_CORRECTION;
  float topY = 20 * DPMM * MAGIC_H_CORRECTION;
  
  float mmX = DPMM * MAGIC_W_CORRECTION;
  float mmY = DPMM * MAGIC_H_CORRECTION;
  
  float cmX = 10 * mmX;
  float cmY = 10 * mmY;
  
  //Draw 10cm rulers to compare
  page.line(0, topY, 0, topY + (cmY * 10));
  page.line(leftX, 0, leftX + (cmX * 10), 0);
  
  int len;
  for (int i = 0; i < 10; i++) {
    page.text(i + "", 6 * mmX, topY + (cmY * i) + (FONT_SIZE / 2));
    page.text(i + "", leftX + (cmX * i) - (FONT_SIZE / 4), 6 * mmY);
    for (int m = 0; m < 10; m++) {
      if (m == 0 || m == 5) {
        len = 5;
      } else {
        len = 3;
      }
      page.line(0, topY + (cmY * i) + (m * mmY), len * mmX, topY + (cmY * i) + (m * mmY));
      page.line(leftX + (cmX * i) + (m * mmX), 0, leftX + (cmX * i) + (m * mmX), len * mmY);
    }
  }
  
  page.line(0, topY + (cmY * 9) + (10 * mmY), 5 * mmX, topY + (cmY * 9) + (10 * mmY));
  page.text(10 + "", 6 * mmX, topY + (cmY * 10) + (FONT_SIZE / 2));
  
  page.line(leftX + (cmX * 9) + (10 * mmX), 0, leftX + (cmX * 9) + (10 * mmX), 5 * mmY);
  page.text(10 + "", leftX + (cmX * 10) - (FONT_SIZE / 4), 6 * mmY);
  
  page.noFill();
  page.rect(0, 0, 10 * DPMM, 10 * DPMM);
  page.rect(((16 * COLUMNS) * DPMM) - (10 * DPMM) - 1, 0, 10 * DPMM, 10 * DPMM);
  page.rect(((16 * COLUMNS) * DPMM) - (10 * DPMM) - 1, ((ROWS * (SPACING / DPMM)) * DPMM) - (10 * DPMM) - 1, 10 * DPMM, 10 * DPMM);
  page.rect(0, ((ROWS * (SPACING / DPMM)) * DPMM) - (10 * DPMM) - 1, 10 * DPMM, 10 * DPMM);
  
  page.text((16 * COLUMNS) + "mm", ((16 * COLUMNS) * DPMM) - (10 * DPMM), 12 * DPMM);
  page.text((ROWS * (SPACING / DPMM)) + "mm", 11 * DPMM, ((ROWS * (SPACING / DPMM)) * DPMM) - DPMM);
  
  page.endDraw();
  page.save("calibration_" + PAGE_W + "x" + PAGE_H + "_" + COLUMNS + "strips_" + ROWS + "frames_" + PITCH + "_" + DPI + "dpi.tif");
  exit();
}

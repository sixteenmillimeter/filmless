W = 192;//12 strips
//H = 251.45999; //33 frames long pitch
H = 250.87791; //33 frames short pitch

module block (x, y) {
    translate([x, y, 0]) cube([10, 10, 10]);
}

projection () {
    block(0, 0);
    block(W - 10, 0);
    block(W -10, H - 10);
    block(0, H - 10);
}
W = 192;
H = 251.45999;

module block (x, y) {
    translate([x, y, 0]) cube([10, 10, 10], center = true);
}

projection () {
    block(0, 0);
    block(W - 10, 0);
    block(W -10, H - 10);
    block(0, H - 10);
}
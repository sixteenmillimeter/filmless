STRIPS = 12;
FRAMES = 33;
PERFS = "single";
PITCH = "long";

module rounded_cube (cube_arr = [1, 1, 1], d = 0, center = false) {
	off_x = 0;
	off_y = 0;
	r = d/2;
	union () {
		cube([cube_arr[0] - d, cube_arr[1], cube_arr[2]], center = center);
		cube([cube_arr[0], cube_arr[1] - d, cube_arr[2]], center = center);
		translate ([1 * (cube_arr[0] / 2) - r , 1 * (cube_arr[1] / 2)- r, 0]) cylinder(r = r, h = cube_arr[2], center = center);
		translate ([-1 * (cube_arr[0] / 2) + r, -1 * (cube_arr[1] / 2) + r, 0]) cylinder(r = r, h = cube_arr[2], center = center);
		translate ([1 * (cube_arr[0] / 2) - r, -1 * (cube_arr[1] / 2) + r, 0]) cylinder(r = r, h = cube_arr[2], center = center);
		translate ([-1 * (cube_arr[0] / 2) + r, 1 * (cube_arr[1] / 2)- r, 0]) cylinder(r = r, h = cube_arr[2], center = center);
	}
}

module 16mm_perf () {
    $fn = 10;
    PERF_W = 1.829;
    PERF_H = 1.27;
    rounded_cube([PERF_W, PERF_H, 2], d = .5, center = true);
}

module 16mm_film (frames = 10, double = false, long = true) {
    THICKNESS = 0.0047 * 25.4;
    WIDTH = 16;
    SPACING_LONG = 7.62;    //long pitch (projection)
    SPACING_SHORT = 7.605;  //short pitch
    PERF_OFFSET = (1.829 / 2) + .85;
    difference () {
        if (long) {
            cube([WIDTH, SPACING_LONG * frames, THICKNESS], center = true);
        } else {
            cube([WIDTH, SPACING_SHORT * frames, THICKNESS], center = true);
        }
        if (long) {
            OFFSET = (SPACING_LONG * frames) / 2;
            for (i = [0 : frames]) {
              translate([8 - PERF_OFFSET, -OFFSET + SPACING_LONG * i, 0]) 16mm_perf();  
            }
            if (double) {
              for (i = [0 : frames]) {
                translate([-8 + PERF_OFFSET, -OFFSET + SPACING_LONG * i, 0]) 16mm_perf();  
                }
            }
        } else {
            OFFSET = (SPACING_SHORT * frames) / 2;
            for (i = [0 : frames]) {
              translate([8 - PERF_OFFSET, -OFFSET + SPACING_LONG * i, 0]) 16mm_perf();  
            }
            if (double) {
              for (i = [0 : frames]) {
                translate([-8 + PERF_OFFSET, -OFFSET + SPACING_LONG * i, 0]) 16mm_perf();  
                }
            }
        }
    }
}

projection() for (i = [0:STRIPS - 1]) {
    translate([16.01 * i, 0, 0]) {
        16mm_film(FRAMES, PERFS == "double", PITCH == "long");
    }
}

echo("STRIP LENGTH", (PITCH == "long" ? 7.62 : 7.605) * FRAMES, "mm");
echo("PAGE WIDTH", 16 * STRIPS, "mm");
echo("PITCH", PITCH);
echo("PERFS", PERFS);
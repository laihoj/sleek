//https://datasheet.lcsc.com/szlcsc/KDS-Daishinku-KDS-32-768KHz-12-5PF-20ppm_C93231.pdf

DST1610A_x = 1;
DST1610A_y = 1.6;
DST1610A_z = 0.45;


module DST1610A(x, y, z, centering) {
    translate([x, y, z])
    cube([DST1610A_x, DST1610A_y, DST1610A_z], centering);
}

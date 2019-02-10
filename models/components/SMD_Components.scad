//_0804();
//_0603();
//_0402();




module _0804(x, y, z, centering) {
    translate([x, y, z])
    cube([2.0, 1.0, 1.0],centering);
}

module _0603(x, y, z, centering) {
    translate([x, y, z])
    cube([1.6, 0.8, 0.8],centering);
}

module _0402(x, y, z, centering) {
    translate([x, y, z])
    cube([1.0, 0.5, 0.5],centering);
}

module _0201(x, y, z, centering) {
    translate([x, y, z])
    cube([0.6, 0.3, 0.3],centering);
}
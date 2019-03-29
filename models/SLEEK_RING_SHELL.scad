/************************
* SLEEK SHELL RING
* credit: Jaakko Laiho, March 29 2019
*************************/



//Deciding between testing and producing? change these
detail = 120;    //increase for higher quality. 120 is pretty nice
TESTING = false; //false: 3D-printable. true: inspect simulation

/************************
*
* ADJUST THESE PARAMETERS TO CUSTOMISE THE RING
* all units in mm
* 
*************************/
pcb_x = 13;                //Ask a PCB designer to define this
pcb_y = 18;                //Ask a PCB designer to define this
pcb_z = 0.6;               //Ask a PCB designer to define this
finger_circumference = 52; //Ask a customer to define this.
ring_height = 8;           //Ask a designer
cover_height = 2;          //Ask a designer //at max cavity value
delta = 0.6;               //Ask the manufacturer this. Minimum manufacturable size


/*--------------------- 
NO TOUCH FROM HERE BELOW
-----------------------*/

//calculated parameters
Df = finger_circumference / 3.14;   //
b = min(pcb_x, pcb_y);  //Assumption of orientation
z = pcb_z;
h = ring_height;
Dai = Df;               //diameter of shell a, inner
Dao = Dai + 2*delta;    //diameter of shell a, outer
a = 2 * atan(Dao / b);  //optimal angle between PCBs to just fit
C = sqrt(1/4 * (b * b + Df * Df)) - Df/2 + z * sin(a); //cavity size between shells necessary to fit PCBs
Dbi = Dao + 2*C;        //diameter of shell b, inner
Dbo = Dbi + 2*delta;    //diameter of shell b, outer
cover_height_effective = min(cover_height, C);  //cover may be at most as sizeable as the cavity








//calling the functions that draw the shape
if(TESTING) {
    visually_confirm_properness_ring();
} else {
    printable_layout_ring();
}


//definition
module printable_layout_ring() {
    //inner ring
    rotate([90,0,0])
    translate([0, cover_height_effective, 0]) {
        shell(h, Dai, Dao);
        cover(0, -cover_height_effective, 0);
    }
    
    //inner ring
    rotate([270,0,0])
    translate([0, -h -cover_height_effective, Dbo + 3]) {
        shell(h, Dbi, Dbo);
        rotate([180, 0, 0])
        translate([0,-h * 2 - cover_height_effective,0])
        cover(0, h, 0);
    }
}

//definition
module visually_confirm_properness_ring() {
    PCBs(pcb_x, pcb_y, pcb_z, finger_circumference, 4);
    shell(h, Dai, Dao);
    //cover(0, -d, 0);
    shell(h, Dbi, Dbo);
    rotate([180, 0, 0])
    translate([0,-h * 2 - cover_height_effective,0])
    cover(0, h, 0);
}

//definition
module PCBs(x, y, z, c, n) {
    translate([- x /2, 0, - Df / 2 - z - delta])
    cube([x, y, z]);
    if(n > 1) {
        for(i=[1:n-1]) {
            rotate([0, 360 - (a - 180)*i, 0])
            translate([- pcb_x /2, 0, - Df / 2 - z - delta])
            cube([pcb_x, pcb_y, pcb_z]);
        }
    }
}

//definition
module shell(h, d1, d2) {
    difference() {
        rotate([270, 0, 0])
        cylinder(h=h, d=d2, $fn=detail);
        rotate([270, 0, 0])
        translate([0,0, -1])
        cylinder(h=h + 2, d=d1, $fn=detail);
    }
}

//definition
module cover(x, y, z) {
    translate([x, y, z])
    difference() {
        union() {
            //top half of cylinder
            rotate([270, 0, 0])
            translate([0,0,+cover_height_effective/2])
            cylinder(h=cover_height/2, d=Dbo, $fn=detail);
            //rouded outer edge
            rotate([90,0,0])
            translate([0,0,-cover_height_effective/2])
            torus(Dbo);
            //rouded inner edge
            rotate([90,0,0])
            translate([0,0,-cover_height_effective/2])
            torus(Df + cover_height_effective * 2);
            //bottom half of cylinder: space between donuts
            difference() {
                rotate([270, 0, 0])
                cylinder(h=cover_height_effective/2, d = (Dbo + Dbi) / 2 - cover_height_effective + delta, $fn=detail);
                rotate([270, 0, 0])
                translate([0,0,-1])
                cylinder(h=cover_height_effective/2 + 2, d = Df + cover_height_effective, $fn=detail);
                
            }
        }
        //finger hole
        rotate([270, 0, 0])
        translate([0,0, -1])
        cylinder(h=h, d=Dai, $fn=detail);
    }
}

module torus(diameter) {
    rotate_extrude(convexity=10,$fn=detail)
    translate([diameter/2 - cover_height_effective/2, 0, 0])
    circle(d=cover_height_effective,$fn=detail);
}

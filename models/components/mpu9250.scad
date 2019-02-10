//http://www.invensense.com/wp-content/uploads/2015/02/PS-MPU-9250A-01-v1.1.pdf

mpu9250_x = 3;
mpu9250_y = 3;
mpu9250_z = 1;

module mpu9250(x, y, z, centering) {
    translate([x, y, z])
    cube([mpu9250_x, mpu9250_y, mpu9250_z], centering);
}
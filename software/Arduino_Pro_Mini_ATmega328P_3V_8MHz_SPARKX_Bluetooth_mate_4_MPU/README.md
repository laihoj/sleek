# Configure your hardware using serial inputs.





## Request device positional state (you can mix&match rpyagmAGM as long as start is '!' and end is '$'):
'!' start symbol
- r to request roll
- p to request pitch
- y to request yaw
- a to request real acceleration
- g to request real gyroscopic force
- m to request real magnetic force
- A to request acceleration in raw measurement unit
- G to request gyroscopic in raw measurement unit
- M to request magnetic in raw measurement unit
'$' end symbol

##### for example: !rpy$ will request roll, pitch, and yaw


## Configure your device. Device responds in format #{response}$:
- '?s' to put IMU to sleep
- '?w' to put IMU to wake
- '?o' to request 'ok'
- '?m' to set output mapping max value
- '?n' to set output mapping min value
- '?d' to set manual delay. (Use in combination with constant output)
- '?p{N}' change output mode:
#### Change output mode:
0. '?p0' for request-based output
1. '?p1' to constantly output mapped roll, pitch, and yaw
2. '?p2' to constantly output real acceleration
3. '?p3' to constantly output real gyroscopic force
4. '?p4' to constantly output real magnetic force
5. '?p5' to constantly output acceleration in raw measurement unit
6. '?p6' to constantly output gyroscopic in raw measurement unit
7. '?p7' to constantly output magnetic in raw measurement unit

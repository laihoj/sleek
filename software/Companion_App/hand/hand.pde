int fingerLength = 100;
int fingerWidth = 30;
int palmDiameter = 200;
boolean THUMB = true;
Hand hand;

Finger finger1;

void setup() {
  size(360,640);
  hand = new Hand(new PVector(width / 2, height * 2 / 3));
  
  finger1 = new Finger(hand, radians(-20), THUMB);
  hand.add(finger1);
  hand.add(new Finger(hand, radians(60)));
  hand.add(new Finger(hand, radians(90)));
  hand.add(new Finger(hand, radians(120)));
  hand.add(new Finger(hand, radians(150))); 
}

void draw() {
  background(0);
  
  //lets make it move by bending a finger based on the mouse
  finger1.bend(mouseY / (float) height * 360);
  hand.display();
}

//golden ratio
float gr(float f) {
  return f / 1.618;
}

class Finger {
  Segment anatomy;
  boolean thumb;
  Finger(Hand hand, float positionAngle, boolean thumb) {
    PVector fingerPosition = new PVector(palmDiameter / 2, 0);
    fingerPosition.rotate(positionAngle);
    //A finger consists of 3 digits
    anatomy = new Segment(fingerLength, fingerWidth, (int)(hand.palm.x - fingerPosition.x), (int)(hand.palm.y - fingerPosition.y));
    anatomy.setNext(new Segment(gr(fingerLength), fingerWidth));
    anatomy.setNext(new Segment(gr(gr(fingerLength)), fingerWidth));
    this.thumb = thumb;
  }
  
  Finger(Hand hand, float positionAngle) {
    this(hand, positionAngle, false);
  }
  
  void display() {
    pushMatrix();
    //if(this.thumb)
    //  rotate(radians(5));
    anatomy.display();
    popMatrix();
  }
  
  void bend(float angle) {
    if(this.thumb)
      angle *= -1;
    anatomy.bend(angle);
  }
}

class Segment {
  Segment next;
  int fingerLength, fingerWidth, x, y;
  int angle;
  Segment(int fingerLength, int fingerWidth, int x, int y) {
    this.fingerLength = fingerLength;
    this.fingerWidth = fingerWidth;
    this.x = x;
    this.y = y;
    this.angle = 0;
    this.next = null;
  }
  
  Segment(int fingerLength, int fingerWidth) {
    this(fingerLength, fingerWidth, 0, 0);
  }
  
  Segment(float fingerLength, float fingerWidth) {
    this((int)fingerLength, (int)fingerWidth, 0, 0);
  }
  
  void bend(float angle) {
    this.angle = (int)angle;
    if(this.next != null)
    next.bend(angle);
  }
  
  void setNext(Segment seg) {
    if(this.next == null)
      this.next = seg;
    else 
      next.setNext(seg);
  }
  void display() {
    strokeWeight(fingerWidth);
    pushMatrix();
    translate(x, y);
    rotate(-radians(angle));
    line(0, 0, 0, -fingerLength);
    if(next != null) {
      pushMatrix();
      translate(0, -fingerLength);
      next.display();
      popMatrix();
    }
    popMatrix();
  }
}

class Hand {
  ArrayList<Finger> fingers;
  PVector palm;
  Hand(PVector palm) {
    fingers = new ArrayList<Finger>();
    this.palm = palm;
  }
  
  
  void display() {
    //palm
    noStroke();
    fill(255, 100);
    ellipse(palm.x, palm.y, palmDiameter, palmDiameter);
    
    //Segments
    strokeWeight(20.0);
    stroke(255, 100);
    
    for(Finger finger: fingers) {
      finger.display();
    }
  }
  
  Hand add(Finger finger) {
    this.fingers.add(finger);
    return this;
  }
}

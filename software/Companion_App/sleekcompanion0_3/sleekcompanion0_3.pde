import commands.*;
import displays.*;
import hailo.*;
import styles.*;
import widgets.*;

import SleekDB.*;
import SleekBT.*;

import SleekUtils.*;

import commands.*;

import java.util.HashSet;
import java.util.Set;
import java.util.LinkedHashSet;


import android.content.Intent;
import android.os.Bundle;


import ketai.net.bluetooth.*;
import ketai.ui.*;
import ketai.net.*;

SleekBluetooth bt;
String info = "";
KetaiList klist;


public PApplet parent = this;
Database db;
DeviceCollection devices = new DeviceCollection();  //Here happens the connection logic
final String user = "jaakko";
//final String verificationRequest = "?o$";

View MAIN_MENU;
TransmittingStateBox transmittingState;
Node hand;

final int framerate = 20;

public void setup() {
  final String url = "https://sleekgestures.herokuapp.com/";
  db = new Database(url);
  frameRate(framerate);
  fullScreen();
  
  
  new App(this, Logging.NONE);
  
  new styles.Container("View");
  new NodeStyle("NodeStyle");
  new NodeLabelStyle("NodeLabelStyle");
  new NodeCollectionStyle("NodeCollectionStyle");
  new NodeCollectionLabelStyle("NodeCollectionLabelStyle");
  new NavButtonStyle("NavButtonStyle")
    .new NavButtonStyleHovering("NavButtonStyleHovering")
    .new NavButtonStylePressed("NavButtonStylePressed");
  new TransmittingBoxStyle("StateBox")
    .new Hovering()
    .new Pressed()
    .new On();    
  
  MAIN_MENU = new View(new Point(), "Main menu", "View");
  
  hand = new Node(new Point(App.width() / 2, App.height() / 2), "Click\nTo Add\nNode", "NodeCollectionStyle");
  MAIN_MENU.add(hand.setOnEvent("onMouseClick", new BTShowPairedDevices()));
  
  
  String[] styles = {"On"};
  transmittingState = new TransmittingStateBox(new Point(5, 5), "Track Motion", styles); 
  transmittingState.setOnEvent("onMouseClick", new SetOutputModeTo1());
  MAIN_MENU.add(transmittingState);
  
  new OpenConnectionToKnownBluetoothDevices().queue();
  
  
}
public void draw() {
  //for(Device device: devices.values()) {
  //  if(transmittingState.state == 1) {
  //    if(device.verified()) {
  //      device.requestOutput();
  //    }
  //  }
  //}
}
  
  
  public class SetOutputModeTo1 extends AbstractCommand {
    public void execute() {
      for(Device device: devices.values()) {
        if(device.verified()) {
          if(device.requestState == 0) {
            device.setDelay(200);
            device.setRequestStateToConstantRPY();
          } else {
            device.setDelay(10);
            device.setRequestStateTo0();
          }
        }
      }
    }
  }
  
  

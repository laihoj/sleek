//Own library containing basic UI stuff
import hailo.*;
import widgets.Button;
import displays.GradientRect;

//required for BT enabling on startup
import android.content.Intent;
import android.os.Bundle;



//Processing android mode bluetooth library
import ketai.net.bluetooth.*;
import ketai.ui.*;
import ketai.net.*;

KetaiBluetooth bt;
String info = "";
KetaiList klist;

PApplet parent = this;
//********************************************************************
// The following code is required to enable bluetooth at startup.
// Remember to update sketch permissions!
//********************************************************************
void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  bt = new KetaiBluetooth(this);
  

}


void onActivityResult(int requestCode, int resultCode, Intent data) {
  bt.onActivityResult(requestCode, resultCode, data);
}


//********************************************************************

void setup() {
  
  //20 frames per second. Too high framerate -> microcontroller BT buffer becomes crowded
  frameRate(60);
  
  fullScreen();
  //size(360,640);
  new App(this, Logging.DEBUG);
  //background(255, 128, 0);
  View MAIN_MENU = new View(new Point(), "Main menu", "Container");
  MAIN_MENU.add(new Button(new Point(App.width() / 2, App.height() * 1 / 5),"Keyboard", "Button", new KeyboardToggle()));
  MAIN_MENU.add(new Button(new Point(App.width() / 2, App.height() * 2 / 5),"Discover", "Button", new BTDiscover()));
  MAIN_MENU.add(new Button(new Point(App.width() / 2, App.height() * 3 / 5),"Connect", "Button", new BTConnect()));
  MAIN_MENU.add(new Button(new Point(App.width() / 2, App.height() * 4 / 5),"Start", "Button", new BTStart()));
  
  MAIN_MENU.add(new GradientRect(0,132,180,0,200,180));
  //start listening for BT connections
  bt.start();
  
  bt.connectToDeviceByName("Sleek0101");
  bt.connectToDeviceByName("00:0E:0E:0D:7B:01");
  bt.connectToDeviceByName("Sleek0100");
  bt.connectToDeviceByName("00:0E:0E:0D:77:9D");
}

public void draw() {}

void onBluetoothDataEvent(String who, byte[] data) {
  
  //if(isConfiguring)
  //  return;

  ////KetaiOSCMessage is the same as OscMessage
  ////   but allows construction by byte array
  //KetaiOSCMessage m = new KetaiOSCMessage(data);
  //if(m.isValid()) {
  //  if(m.checkAddrPattern("/remoteMouse/"))
  //  if(true) {
  //    if(m.checkTypetag("ii"))
  //    if(true) {
  //      remoteMouse.x = m.get(0).intValue();
  //      remoteMouse.y = m.get(1).intValue();
  //    }
  //  }
  //}
}

void onKetaiListSelection(KetaiList klist)
{
  String selection = klist.getSelection();
  println("Connecting to: " + selection);
  bt.connectToDeviceByName(selection);

  //dispose of list for now
  klist = null;
}

public class BTDiscover extends AbstractCommand {
  BTDiscover() {}
  public void execute() {
    bt.discoverDevices();
  }
}

public class BTStart extends AbstractCommand {
  BTStart() {}
  public void execute() {
    bt.start();
  }
}

public class KeyboardToggle extends AbstractCommand {
  KeyboardToggle() {}
  public void execute() {
    KetaiKeyboard.toggle(parent);
  }
}





public class BTConnect extends AbstractCommand {
  BTConnect() {}
  public void execute() {
    //If we have not discovered any devices, try prior paired devices
    if(bt.getDiscoveredDeviceNames().size() > 0) {
    ArrayList<String> list = bt.getDiscoveredDeviceNames();
      klist = new KetaiList(parent, list);
    }
    else if(bt.getPairedDeviceNames().size() > 0) {
      ArrayList<String> list = bt.getPairedDeviceNames();
      klist = new KetaiList(parent, list);
    }
  }
}

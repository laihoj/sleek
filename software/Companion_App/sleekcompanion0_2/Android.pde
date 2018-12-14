import android.content.Intent;
import android.os.Bundle;
//import android.util.DisplayMetrics;


import ketai.net.bluetooth.*;
import ketai.ui.*;
import ketai.net.*;

KetaiBluetooth bt;
String info = "";
KetaiList klist;

//issue with parallelism. Fix: First come, first served.
boolean handlingBTDataEvent = false;

void onBluetoothDataEvent(String who, byte[] data) {
  if(!handlingBTDataEvent) {
    handlingBTDataEvent = true;
    String result = "";
    for(int i = 0; i < data.length; i++) {
      result += (char)data[i];
    }
    println(who + " " + result);
    new Thread(new NewDataPoint(who, ""+ System.currentTimeMillis(), result)).start();
    handlingBTDataEvent = false;
  }
}



void onKetaiListSelection(KetaiList klist)
{
  String deviceName = klist.getSelection();
  new Thread(new Connect(deviceName)).start();
  
  //dispose of list for now
  klist = null;
}

void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  bt = new KetaiBluetooth(this);
  
}


void onActivityResult(int requestCode, int resultCode, Intent data) {
  bt.onActivityResult(requestCode, resultCode, data);
}





public class BTShowPairedDevices extends AbstractCommand {
  BTShowPairedDevices() {}
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




//TODO: rename to connectByName
public class Connect implements Runnable {
  String deviceName;
  public Connect(String name) {
    this.deviceName = name;
  }
  public void run() {
    println("Connecting to: " + deviceName);
    boolean connected = bt.connectToDeviceByName(deviceName);
    String address = bt.lookupAddressByName(deviceName);
    if(connected)
      addNode(deviceName, address);
    try {
      db.saveDevice(address, "UUID unknown", deviceName, user);
    } catch(Exception e) {
      println(e);
    }
  }
}



public class ConnectByJSONObject implements Runnable {
  JSONObject device;
  final String address, name, uuid, user;
  public ConnectByJSONObject(JSONObject device) {
    this.device = device;
    this.address = device.getString("address");
    this.name = device.getString("name");
    this.uuid = device.getString("uuid");
    this.user = device.getString("user");
    println(address + " " + name + " " + uuid + " " + user + " being used");
    if(!nodes.contains(this.name)) {
      SensorNode sensor = new SensorNode(device);
      nodes.putByName(this.name, sensor);
      nodes.putByAddress(this.address, sensor);
    }
  }
  public void run() {
    println("Connecting to: " + this.address);
    bt.connectDevice(this.address);
    addNode(this.name, this.address);
    try {
      db.saveDevice(this.address, this.name, this.name, this.user);
    } catch(Exception e) {
      println(e);
    }
  }
}

void addNode(String name, String address) {
  boolean nodeAlreadyExists = false;
  //SensorNode sensor;// = new SensorNode(name, address);
      for(Node node: nodeBase.nodes()) {
        if(node.name().equals(name)) {
          nodeAlreadyExists = true;
          //if(nodes.getByName(name) != null)
          //{
          //  sensor = nodes.getByName(name);
          //  sensor.setConnected(true);
          //  sensor.setNode(node);
          //}
        }
      }
      if(!nodeAlreadyExists) {
        Node node = new Node(new Point(App.width() / 2, App.height() * 1 / 3), name, "NodeStyle");
        nodeBase.add((Node)node.setOnEvent("onMouseDrag", new Drag(node)));
      } else {
        new Print("Device already connected", Logging.WARNING);
      }
      
}

import SleekDB.*;

import SleekUtils.*;

import hailo.*;
import commands.*;

import widgets.*;
import java.util.HashSet;

PApplet parent = this;
Database db;
View MAIN_MENU;
SensorNodeCollection nodes = new SensorNodeCollection();  //Here happens the connection logic
TransmittingStateBox transmittingState;
Node nodeBase;  //These are visual elements
float ts;
final String user = "jaakko";
public void setup() {
  final String url = "https://sleekgestures.herokuapp.com/";
   db = new Database(url);
    /*
     * Framerate is defined in setup, not settings (Try to just remember this)
     * */
    frameRate(20);
        //size(360,640);
        fullScreen();
        

    
    /*
     * And the developer said, let there be an app!
     * (In debugging mode, that is)
     * */
    new App(this, Logging.NONE);
    
    /*
     * importing styles
     * */
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
    
    nodeBase = new Node(new Point(App.width() / 2, App.height() / 2), "Click\nTo Add\nNode", "NodeCollectionStyle");
    MAIN_MENU.add(nodeBase.setOnEvent("onMouseClick", new BTShowPairedDevices()));
    
    
    String[] styles = {"On"};
    transmittingState = new TransmittingStateBox(new Point(5, 5), "Track Motion", styles); 
    MAIN_MENU.add(transmittingState);
    
    new ConnectToKnownBluetoothDevices().queue();
    
  }
  
  /*
   * This function stub must be stated, otherwise the app runs only the first frame.
   * Essentially, it makes sure the app keeps on looping (drawing?) infinitely
   * */
  public void draw() {
    if(transmittingState.state == 1) {
      nodes.requestState();
    }
  }
  
  public class NewDataPoint extends AbstractCommand implements Runnable {
    String deviceAddress;
    String time;
    String data;
    public NewDataPoint(String deviceAddress, String time, String data) {
      this.deviceAddress = deviceAddress;
      this.time = time;
      this.data = data;
    }
    public void execute() {
      try {
        db.saveDatapoint(deviceAddress, time, data);
      } catch(Exception e) {}
    }
    public void run() {
      execute();
    }
  }
  
  public class ConnectToKnownBluetoothDevices extends AbstractCommand {
    public ConnectToKnownBluetoothDevices() {}
    public void execute() {
      println("Connecting to known bluetooth devices");
      try {
        String response = db.getDevicesByUser(user);
        JSONArray devicesArray = JSONArray.parse(response);
        for(int i = 0; i < devicesArray.size(); i++) {
          JSONObject device = devicesArray.getJSONObject(i);
          String deviceName = device.getString("name");
          println(deviceName + " found");
          new Thread(new ConnectByJSONObject(device)).start();
        }
      } catch(Exception e) {
        println("ConnectToKnownBluetoothDevices caught " + e);
      }
    }
  }

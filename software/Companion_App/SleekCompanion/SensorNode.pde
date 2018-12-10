public class SensorNode implements java.io.Serializable {
  boolean connected;  //adjusted once during beginning; helper to make sure stuff works
  boolean available = true;  //if stuff profoundly broken, switch this to false
  final String name;
  String address;
  transient int roll, pitch, yaw; //transient has to do with serializability
  Label label;
  public SensorNode(String name, String address) {
    this.name = name;
    setAddress(address);
    setPitch(0);
    setRoll(0);
    setYaw(0);
    
    setLabel(new Label(new Point(App.width() / 2, App.height() / 2 + nodes.size() * 20), name, "Label"));
    MAIN_MENU.add(label());
  }
  
  
  public void setAddress(String address) {
    this.address = address;
  }
  
  
  public void setRoll(int roll) {
    this.roll = roll;
  }
  
  
  public void setPitch(int pitch) {
    this.pitch = pitch;
  }
  
  
  public void setYaw(int yaw) {
    this.yaw = yaw;
  }
  
  
  public void setConnected(boolean bool) {
    this.connected = bool;
  }
  
  
  public boolean connected() {
    return connected;
  }
  
  
  public String name() {
    return this.name;
  }
  
  
  public String address() {
    return this.address;
  }
  
  
  public Label label() {
    return this.label;
  }
  
  
  public int roll() {
    return this.roll;
  }
  
  
  public int pitch() {
    return this.pitch;
  }
  
  
  public int yaw() {
    return this.yaw;
  }
  
  
  public void setLabel(Label label) {
    this.label = label;
  }
  
  //Test for infinite recursion
  public void requestState() {
    String request = "!rpy$";
    if(available) {
      if(connected) { 
        bt.writeToDeviceName(name(), request.getBytes());
      } else {
        if(connectRoutine()) { //if connection successful, try again
          available = true;
          requestState();
        }
      }
    }
  }
  
  //Sorry for this piece of crap.
  public boolean connectRoutine() {
    if(verifyConnection()) {
      connectionVerified();
      return true;
    } else if(bt.connectToDeviceByName(name)) {
      return true;
    } else {
      this.available = false;
      return false;
    }
  }
  
  //Sorry for this too.
  public boolean verifyConnection() {
    new Print(this.name() + " connection not verified. Verifying...", Logging.WARNING);
    String address = bt.lookupAddressByName(name); //what is lookup output? hopefully: not null
    setAddress(address);
    nodes.putByAddress(address(), this);
    serialiseNodes();
    return address != null && address.length() > 0; //if address is found, connection is verified
  }
  
  //And this
  public void connectionVerified() {
    new Print("Connection verified.", Logging.WARNING);
    setConnected(true);
  }
  
  public void updateState(int roll, int pitch, int yaw) {
    setRoll(roll);
    setPitch(pitch);
    setYaw(yaw);
    this.label.setName(this.name() + "; Roll:" + this.roll() +", Poll:" + this.pitch() + ", Yaw:" + this.yaw());
  }
}

public class SensorNodeCollection implements java.io.Serializable {
  HashMap<String, SensorNode> nodesByName = new HashMap<String, SensorNode>();
  HashMap<String, SensorNode> nodesByAddress = new HashMap<String, SensorNode>();
  
  public SensorNodeCollection() {}
  
  public void putByName(String name, SensorNode node) {
    nodesByName.put(name, node);
  }
  
  public void putByAddress(String address, SensorNode node) {
    nodesByAddress.put(address, node);
  }
  
  public SensorNode getByName(String name) {
    return nodesByName.get(name);
  }
  
  public SensorNode getByAddress(String address) {
    return nodesByAddress.get(address);
  }
  
  public ArrayList<SensorNode> values() {
    ArrayList<SensorNode> byName = new ArrayList<SensorNode>();//(ArrayList) (nodesByName.values());
    ArrayList<SensorNode> byAddress = new ArrayList<SensorNode>();// (ArrayList) (nodesByAddress.values());
    for(SensorNode node: nodesByName.values()) {
      byName.add(node);
    }
    for(SensorNode node: nodesByAddress.values()) {
      byAddress.add(node);
    }
    byName.removeAll(byAddress);
    byName.addAll(byAddress);
    return byName;
  }
  
  public int size() {
    return values().size();
  }
}

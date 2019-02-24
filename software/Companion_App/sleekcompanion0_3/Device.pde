public class Device {
  String name, address, uuid, user;
  Node node = null;
  boolean verified = false;
  int roll, pitch, yaw;
  int requestState = 0;
  public Device(String name, String address, String uuid, String user) {
    this.name = name;
    this.address = address;
    this.uuid = uuid;
    this.user = user;
    setPitch(0);
    setRoll(0);
    setYaw(0);
    println("Device " + name + " at " + address + " created");
  }
  
  public Device(JSONObject json) {
    this(json.getString("name"), json.getString("address"), json.getString("uuid"), json.getString("user"));
  }
  public void   setNode    (Node node)                   {this.node = node;}
  
  public void    setAddress (String address)              {this.address = address;}
  public void    setUUID    (String uuid)                 {this.uuid = uuid;}
  public void    setUser    (String user)                 {this.user = user;}
  public void    setRoll    (int roll)                    {this.roll = roll;}
  public void    setPitch   (int pitch)                   {this.pitch = pitch;}
  public void    setYaw     (int yaw)                     {this.yaw = yaw;}
  public Node    node       ()                            {return this.node;}
  public String  name       ()                            {return this.name;}
  public String  address    ()                            {return this.address;}
  public boolean verified   ()                            {return this.verified;}
  public int     roll       ()                            {return this.roll;}
  public int     pitch      ()                            {return this.pitch;}
  public int     yaw        ()                            {return this.yaw;}
  
  public void verify() {
    if(!verified()) {
      this.verified = true; 
      println(name() + " verified");
      setNode(new Node(new Point(App.width() / 2, App.height() * 1 / 3), name, "NodeStyle"));
      hand.add(this.node());
      this.node.setOnEvent("onMouseDrag", new Drag(node));
      new Thread(new RequestSetOutputModeTo0(name(), address())).start();
      //setDelay(100);
    } else {
      println(name() + " is already verified");
    }
  }
  public void requestOutput() {
    new Thread(new RequestOutput(name(), address())).start();
  }
  public void setDelay(int delay) {
    println("Setting delay of " + name() + " to " + delay);
    new Thread(new RequestSetDelay(name(), address(), delay)).start();
  }
  public void setRequestStateToConstantRPY() {
    new Thread(new RequestSetOutputModeToConstantRPY(name(), address())).start();
    this.requestState = 1;
  }
  public void setRequestStateTo0() {
    new Thread(new RequestSetOutputModeTo0(name(), address())).start();
    this.requestState = 0;
  }
}







public class DeviceCollection {
  HashMap<String, Device> nodes = new HashMap<String, Device>();
  
  public DeviceCollection() {}
  
  public void put(String identifier, Device node) {
    nodes.put(identifier, node);
  }
  
  public void remove(String identifier) {
    nodes.remove(identifier);
  }
  
  public Device get(String name) {
    return nodes.get(name);
  }
  
  
  public ArrayList<Device> values() {
    ArrayList<Device> result = new ArrayList<Device>();
    result.addAll(nodes.values());
    Set<Device> set = new LinkedHashSet<Device>();
    set.addAll(result);
    result.clear();
    result.addAll(set);
    return result;
  }
  
  public int size() {
    return values().size();
  }
  public boolean contains(String name) {
    for(Device sensor: this.values()) {
      if(sensor.name().equals(name)) { 
        return true;
      } 
    }
    return false;
  }
  
}








public class RequestOK implements Runnable {
  String name, address;
  public RequestOK(String name, String address) {
    this.name = name;
    this.address = address;
  }
  public void run() {
    if(address != null) {
      bt.write(address, "?o$".getBytes());
    } else {
      bt.writeToDeviceName(name, "?o$".getBytes());
    }
  }
}



public class RequestSetOutputModeToConstantRPY implements Runnable {
  String name, address;
  public RequestSetOutputModeToConstantRPY(String name, String address) {
    this.name = name;
    this.address = address;
  }
  public void run() {
    if(address != null) {
      bt.write(address, "?p1".getBytes());
    } else {
      bt.writeToDeviceName(name, "?p1".getBytes());
    }
  }
}



public class RequestSetOutputModeTo0 implements Runnable {
  String name, address;
  public RequestSetOutputModeTo0(String name, String address) {
    this.name = name;
    this.address = address;
  }
  public void run() {
    if(address != null) {
      bt.write(address, "?p0".getBytes());
    } else {
      bt.writeToDeviceName(name, "?p0".getBytes());
    }
  }
}



public class RequestSetDelay implements Runnable {
  String name, address;
  int delay;
  public RequestSetDelay(String name, int delay) {
    this(name, null, delay);
  }
  public RequestSetDelay(String name, String address, int delay) {
    this.name = name;
    this.address = address;
    this.delay = delay;
  }
  public void run() {
    if(address != null) {
      bt.write(address, ("?d"+delay).getBytes());
    } else {
      bt.writeToDeviceName(name, ("?d"+delay).getBytes());
    }
  }
}



public class RequestOutput implements Runnable {
  String name, address;
  public RequestOutput(String name) {
    this(name, null);
  }
  public RequestOutput(String name, String address) {
    this.name = name;
    this.address = address;
  }
  public void run() {
    if(address != null) {
      bt.write(address, ("!rpy$").getBytes());
    } else {
      bt.writeToDeviceName(name, ("!rpy$").getBytes());
    }
  }
}

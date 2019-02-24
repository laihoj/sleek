import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;

//private ConnectThread mConnectThread;


void onBluetoothDataEvent(String who, byte[] data) {
  
  String result = "";
  for(int i = 0; i < data.length; i++) {
    result += (char)data[i];
  }
  
  //println(who + " " + result); 
  if(result.indexOf("#ok$") != -1? true: false) {
    devices.get(who).verify();
  }
  if(result.charAt(0) == '!' && result.charAt(result.length() - 1) == '$') {
    println(who + ": " + result);
  }
}





public class OpenConnection implements Runnable {
  String deviceName;
  String deviceAddress;
  public OpenConnection(String deviceName) {
    this.deviceName = deviceName;
    this.deviceAddress = null;
  }
  public OpenConnection(String deviceName, String deviceAddress) {
    this.deviceName = deviceName;
    this.deviceAddress = deviceAddress;
  }
  public void run() {
    if(deviceAddress != null) {
      bt.connectDevice(deviceAddress);
    } else {
      bt.getPairedDeviceNames();
      deviceAddress = bt.lookupAddressByName(deviceName);
      println("Connecting to: " + deviceName + " of address " + deviceAddress);
      bt.connectToDeviceByName(deviceName);
    }
    
    Device node = new Device(deviceName, deviceAddress, null, null);
    devices.put(deviceName, node);
    devices.put(deviceAddress, node);
    
    //try {
    //  db.saveDevice(deviceAddress, "UUID unknown", deviceName, user);
    //} catch(Exception e) {
    //  println(e);
    //}
  }
}


public class OpenConnectionByName implements Runnable {
  String deviceName;
  public OpenConnectionByName(String name) {
    this.deviceName = name;
  }
  public void run() {
    new Thread(new OpenConnection(deviceName)).start();
  }
}




public class OpenConnectionByJSONObject implements Runnable {
  JSONObject json;
  final String deviceAddress, deviceName, deviceUuid, deviceUser;
  public OpenConnectionByJSONObject(JSONObject json) {
    this.json = json;
    this.deviceAddress = json.getString("address");
    this.deviceName = json.getString("name");
    this.deviceUuid = json.getString("uuid");
    this.deviceUser = json.getString("user");
  }
  public void run() {
    new Thread(new OpenConnection(deviceName, deviceAddress)).start();
  }
}





public class OpenConnectionToKnownBluetoothDevices extends AbstractCommand {
  public OpenConnectionToKnownBluetoothDevices() {}
  public void execute() {
    try {
      GetDevicesByUser request = new GetDevicesByUser(user);
      Thread thread = new Thread(request);
      thread.start();
      thread.join();
      JSONArray devicesArray = JSONArray.parse(request.response);
      for(int i = 0; i < devicesArray.size(); i++) {
        JSONObject device = devicesArray.getJSONObject(i);
        new Thread(new OpenConnectionByJSONObject(device)).start();
      }
    } catch(Exception e) {
      println("ConnectToKnownBluetoothDevices exception caught " + e);
    }
  }
}

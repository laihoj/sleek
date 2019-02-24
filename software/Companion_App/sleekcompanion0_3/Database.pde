public class SaveDevice implements Runnable {
  String name, address, uuid, user;
  public SaveDevice(String name, String address, String uuid, String user) {
    this.name = name;
    this.address = address;
    this.uuid = uuid;
    this.user = user;
  }
  public void run() {
    try {
      db.saveDevice(this.address, this.name, this.uuid, this.user);
    } catch(Exception e) {
      println(e);
    }
  }
}


public class NewDataPoint implements Runnable {
  String deviceAddress;
  String time;
  String data;
  public NewDataPoint(String deviceAddress, String time, String data) {
    this.deviceAddress = deviceAddress;
    this.time = time;
    this.data = data;
  }
  public void run() {
    try {
      db.saveDatapoint(deviceAddress, time, data);
    } catch(Exception e) {
      println(e); 
    }
  }
}



public class GetDevicesByUser implements Runnable {
  String user;
  String response;
  public GetDevicesByUser(String user) {
    this.user = user;
  }
  public void run() {
    try {
      response = db.getDevicesByUser(user);
    } catch(Exception e) {
      println(e); 
    }
  }
}

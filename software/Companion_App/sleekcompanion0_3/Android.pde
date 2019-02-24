


void onKetaiListSelection(KetaiList klist)
{
  String deviceName = klist.getSelection();
  new Thread(new OpenConnectionByName(deviceName)).start();
  
  //dispose of list for now
  klist = null;
}

void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  bt = new SleekBluetooth(parent);
  bt.getDiscoveredDeviceNames();
  println(bt.toString());
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

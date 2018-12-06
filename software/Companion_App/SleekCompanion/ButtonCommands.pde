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

public class UpdateReadings extends AbstractCommand {
  UpdateReadings() {}
  public void execute() {
    for(SensorNode node: nodes.values()) {
      node.requestState();
    }
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

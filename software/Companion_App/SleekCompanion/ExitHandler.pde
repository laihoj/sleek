import java.io.*;

private void prepareExitHandler() {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run () {
      System.out.println("SHUTDOWN HOOK");
      serialiseNodes();
    }
  }));
}

public void serialiseNodes() {
  new Print("Serialising nodes...", Logging.WARNING);
  try {
    
    FileOutputStream fileOut = new FileOutputStream("/SleekCompanion/tmp/nodes.ser", false); //false means overwrite
    ObjectOutputStream out = new ObjectOutputStream(fileOut);
    out.writeObject(nodes);
    out.close();
    fileOut.close();
    System.out.printf("Serialized data is saved in /tmp/nodes.ser");
  } catch (IOException i) {
    i.printStackTrace();
  }
}

public SensorNodeCollection loadNodesFromTmp() {
  SensorNodeCollection nodes = null;
  try {
   FileInputStream fileIn = new FileInputStream("/SleekCompanion/tmp/nodes.ser");
   ObjectInputStream in = new ObjectInputStream(fileIn);
   nodes = (SensorNodeCollection) in.readObject();
   in.close();
   fileIn.close();
  } catch (java.io.FileNotFoundException e) {
      e.printStackTrace();
      return null;
  } catch (IOException i) {
     i.printStackTrace();
     return null;
  } catch (ClassNotFoundException c) {
     System.out.println("SensorNode class not found");
     c.printStackTrace();
     return null;
  }
  System.out.println("Deserialized SensorNodeCollection...");
  for(SensorNode node: nodes.values()) {
    System.out.println("Name: " + node.name());
    System.out.println("Address: " + node.address());
  }
  return nodes;
}

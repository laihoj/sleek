public class Key extends styles.Button {
  Key(String name) {
    super(name);
    setDimensions(new Dimensions(min(App.width(), App.height()) / 4, min(App.width(), App.height()) / 4));
    setFill(new Color(255, 255, 255));
    setStroke(new Color(125, 125, 125));
  }
}

public class KeyPressedStyle extends Key {
  KeyPressedStyle(String name) {
    super(name);
    setFill(new Color(50, 50, 100));
  }
}

public class KeyHoveringStyle extends Key {
  KeyHoveringStyle(String name) {
    super(name);
    setFill(new Color(0, 200, 180));
  }
}

public class LargeLabelStyle extends styles.Label {
  LargeLabelStyle(String name) {
    super(name);
    setTextSize(35);
  }
}

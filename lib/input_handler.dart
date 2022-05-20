import 'package:crust_dart/src/proto/user_input.pb.dart';

class InputHandler {
  Map<String, KeyTrigger> keyMapping = {};

  void registerKey(String key, {Function? onPressed, Function? onReleased}) {
    keyMapping[key] = KeyTrigger(onPressed, onReleased);
  }

  void handleInput(UserInput event) {
    if (!event.hasKeyEvent() || event.keyEvent.keyState == KeyState.NONE) {
      return;
    }

    print('🎯 $event');
    final trigger = keyMapping[event.keyEvent.key];
    if (trigger == null) {
      return;
    }

    final handler = event.keyEvent.keyState == KeyState.PRESSED
        ? trigger.onPressed
        : trigger.onReleased;
    if (handler != null) {
      handler();
    }
  }
}

class KeyTrigger {
  Function? onPressed;
  Function? onReleased;

  KeyTrigger(this.onPressed, this.onReleased);
}

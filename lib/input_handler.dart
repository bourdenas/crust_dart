import 'package:crust_dart/src/input_manager.dart';
import 'package:crust_dart/src/proto/user_input.pb.dart';

class InputHandler {
  final Map<String, KeyTrigger> _keyMapping = {};

  void install() {
    inputManager.register(this);
  }

  void registerKey(String key, {Function? onPressed, Function? onReleased}) {
    _keyMapping[key] = KeyTrigger(onPressed, onReleased);
  }

  void handle(UserInput event) {
    if (!event.hasKeyEvent() || event.keyEvent.keyState == KeyState.NONE) {
      return;
    }

    print('🎯 $event');
    final trigger = _keyMapping[event.keyEvent.key];
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

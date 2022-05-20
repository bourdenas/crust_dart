import 'package:crust_dart/input_handler.dart';
import 'package:crust_dart/src/proto/user_input.pb.dart';

final inputManager = InputManager();

class InputManager {
  final List<InputHandler> _handlers = [];

  void register(InputHandler handler) {
    _handlers.add(handler);
  }

  void clear() {
    _handlers.clear();
  }

  void handle(UserInput event) {
    for (final handler in _handlers) {
      handler.handle(event);
    }
  }
}

import 'package:crust_dart/src/event_manager.dart';
import 'package:crust_dart/src/proto/event.pb.dart';

class EventHandler {
  final Map<String, Function> _handlers = {};

  void install() {
    eventManager.register(this);
  }

  void register(String eventId, Function handler) {
    _handlers[eventId] = handler;
  }

  void handle(Event event) {
    final handler = _handlers[event.eventId];
    if (handler != null) {
      handler();
    }
  }
}

import 'package:crust_dart/event_handler.dart';
import 'package:crust_dart/src/proto/event.pb.dart';

final eventManager = EventManager();

class EventManager {
  final List<EventHandler> _handlers = [];

  void register(EventHandler handler) {
    _handlers.add(handler);
  }

  void clear() {
    _handlers.clear();
  }

  void handle(Event event) {
    for (final handler in _handlers) {
      handler.handle(event);
    }
  }
}

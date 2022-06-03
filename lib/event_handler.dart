import 'package:crust_dart/src/event_manager.dart';
import 'package:crust_dart/src/proto/event.pb.dart';

class EventHandler {
  final EventHandlerFunc _handler;

  EventHandler(String eventId, this._handler) {
    eventManager.register(eventId, this);
  }

  void handle(Event event) {
    _handler(event);
  }
}

typedef EventHandlerFunc = void Function(Event event);

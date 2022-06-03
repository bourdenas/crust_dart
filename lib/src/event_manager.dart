import 'dart:collection';

import 'package:crust_dart/event_handler.dart';
import 'package:crust_dart/src/proto/event.pb.dart';

final eventManager = EventManager();

class EventManager {
  final _handlers = HashMap<String, EventHandler>();

  void register(String eventId, EventHandler handler) {
    _handlers[eventId] = handler;
  }

  void clear() {
    _handlers.clear();
  }

  void handle(Event event) {
    _handlers[event.eventId]?.handle(event);
  }
}

import 'dart:math';

import 'package:crust_dart/event_handler.dart';
import 'package:crust_dart/src/crust.dart';
import 'package:crust_dart/src/proto/action.pb.dart';
import 'package:crust_dart/src/proto/animation.pb.dart';
import 'package:crust_dart/src/proto/primitives.pb.dart';
import 'package:crust_dart/src/proto/scene_node.pb.dart';

/// Sprite representation in crust.
class Sprite {
  String? id;
  static int _spriteUniqueId = 0;

  Sprite([this.id]);

  /// Create a sprite on specified `position` with given `frameIndex`.
  void create(
    String spriteId,
    Point<int> position, {
    int frameIndex = 0,
  }) {
    id = id ?? '${spriteId}_${_spriteUniqueId++}';

    final action = Action(
      createSceneNode: SceneNodeAction(
        sceneNode: SceneNode(
          id: id,
          position: Vector(x: position.x.toDouble(), y: position.y.toDouble()),
          spriteId: spriteId,
          frameIndex: frameIndex,
        ),
      ),
    );
    crust.execute(action);
  }

  /// Remove the sprite from the scene.
  void destroy() {
    final action = Action(
      destroySceneNode: SceneNodeRefAction(sceneNodeId: id),
    );
    crust.execute(action);
  }

  /// Applies [script] animation on the Sprite.
  ///
  /// If [onDone] is provided it will be invoked when the script finishes
  /// execution.
  /// If [onRewind] is provided it will be invoked when the script restarts
  /// execution.
  /// The [onPartDone] is a map from animation script part name to handlers. If
  /// provided a handler will be invoked when the corresponding script part
  /// finishes execution.
  void playAnimation({
    required AnimationScript script,
    // EventHandler onDone,
    // EventHandler onRewind,
    // Map<String, EventHandler> onPartDone,
    bool reversed = false,
  }) {
    final action = Action(
      playAnimation: AnimationScriptAction(
        sceneNodeId: id,
        script: script,
        speed: 1.0,
      ),
    );
    crust.execute(action);
  }

  void stopAnimation() {
    final action = Action(
      stopAnimation: SceneNodeRefAction(sceneNodeId: id),
    );
    crust.execute(action);
  }

  /// Registers a `handler` that is triggered when this sprite collide with
  /// other sprites.
  ///
  /// `otherId` can be either a `Sprite.id` or the resource id of the `Sprite`.
  void onCollision(String otherId, CollisionHandler handler) {
    EventHandler(
      '${id}_collision',
      (event) => handler(
        this,
        Sprite(event.onCollision.rhsId),
        event.onCollision.intersection,
      ),
    );

    final action = Action(
      onCollision: CollisionAction(
        sceneNodeId: id,
        otherId: otherId,
      ),
    );
    crust.execute(action);
  }
}

typedef CollisionHandler = void Function(
    Sprite lhs, Sprite rhs, Box intersection);

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

  /// Applies an animation `script` on the Sprite.
  ///
  /// If `onDone` is provided, it will be invoked when the script finishes
  /// execution.
  ///
  /// If `onRewind` is provided, it will be invoked when the script restarts
  /// execution, if repeatable.
  ///
  /// If `onSegmentDone` is provided, it will be invoked each time an animation
  /// segment finishes execution.
  void playAnimation({
    required List<Animation> segments,
    int repeat = 1,
    double speed = 1.0,
    String? scriptId,
    AnimationHandler? onDone,
    AnimationHandler? onRewind,
    AnimationHandler? onSegmentDone,
    bool reversed = false,
  }) {
    if (onDone != null) {
      EventHandler(
        '${id}_script_done',
        (event) => onDone(
          event.animationScriptDone.animationId,
          event.animationScriptDone.position,
          event.animationScriptDone.frameIndex,
        ),
      );
    }
    if (onRewind != null) {
      EventHandler(
        '${id}_script_rewind',
        (event) => onRewind(
          event.animationScriptRewind.animationId,
          event.animationScriptRewind.position,
          event.animationScriptRewind.frameIndex,
        ),
      );
    }
    if (onSegmentDone != null) {
      EventHandler(
        '${id}_segment_done',
        (event) => onSegmentDone(
          event.animationScriptRewind.animationId,
          event.animationScriptRewind.position,
          event.animationScriptRewind.frameIndex,
        ),
      );
    }

    final action = Action(
      playAnimation: AnimationScriptAction(
        sceneNodeId: id,
        script: AnimationScript(
          animation: segments,
          id: scriptId,
          repeat: repeat,
        ),
        speed: speed,
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

  /// Registers a `onCollision` and `onDetach` handlers triggered by collisions
  /// with `otherId` sprites.
  ///
  /// `otherId` can be either a `Sprite.id` or the resource id of the `Sprite`.
  void collidesWith(String otherId,
      {CollisionHandler? onCollision, CollisionHandler? onDetach}) {
    if (onCollision != null) {
      EventHandler(
        '${id}_collide',
        (event) => onCollision(
          this,
          Sprite(event.onCollision.rhsId),
          event.onCollision.intersection,
        ),
      );
    }

    if (onDetach != null) {
      EventHandler(
        '${id}_detach',
        (event) => onDetach(
          this,
          Sprite(event.onDetach.rhsId),
          event.onDetach.intersection,
        ),
      );
    }

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

typedef AnimationHandler = void Function(
    String animationId, Vector position, int frameIndex);

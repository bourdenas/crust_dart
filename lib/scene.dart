import 'package:crust_dart/src/crust.dart';
import 'package:crust_dart/src/proto/action.pb.dart';
import 'package:crust_dart/src/proto/primitives.pb.dart';

/// Scene representation in crust.
class Scene {
  String? resource;

  Scene([this.resource]);

  void load({Box? viewport}) {
    final action = Action(
      loadScene: SceneAction(
        resource: resource,
        viewport: viewport,
      ),
    );
    crust.execute(action);
  }
}

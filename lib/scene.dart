import 'package:crust_dart/src/crust.dart';
import 'package:crust_dart/src/proto/action.pb.dart';

/// Scene representation in crust.
class Scene {
  String? resource;

  Scene([this.resource]);

  void load() {
    final action = Action(
      loadScene: SceneAction(resource: resource),
    );
    crust.execute(action);
  }
}

import 'dart:ffi' as ffi;

import 'package:crust_dart/src/event_manager.dart';
import 'package:crust_dart/src/input_manager.dart';
import 'package:crust_dart/src/proto/action.pb.dart';
import 'package:crust_dart/src/proto/config.pbserver.dart';
import 'package:crust_dart/src/proto/event.pb.dart';
import 'package:crust_dart/src/proto/user_input.pb.dart';
import 'package:ffi/ffi.dart';

final crust = Crust();

class Crust {
  late ffi.DynamicLibrary _crustLib;
  late _ExecFuncDart _execute;

  void init(String libPath, CrustConfig config) {
    _crustLib = ffi.DynamicLibrary.open("$libPath/crust_lib.dll");

    final _InitFuncDart init =
        _crustLib.lookup<ffi.NativeFunction<_InitFunc>>('init').asFunction();
    final _RegisterInputHandlerFuncDart registerHandler = _crustLib
        .lookup<ffi.NativeFunction<_RegisterInputHandlerFunc>>(
            'register_input_handler')
        .asFunction();
    final _RegisterEventHandlerFuncDart registerEventHandler = _crustLib
        .lookup<ffi.NativeFunction<_RegisterEventHandlerFunc>>(
            'register_event_handler')
        .asFunction();

    _execute =
        _crustLib.lookup<ffi.NativeFunction<_ExecFunc>>('execute').asFunction();

    final encodedConfig = config.writeToBuffer();
    final ffi.Pointer<ffi.Uint8> bytes =
        malloc.allocate<ffi.Uint8>(encodedConfig.length);
    for (var i = 0; i < encodedConfig.length; i++) {
      bytes.elementAt(i).value = encodedConfig[i];
    }
    final ffi.Pointer<ffi.Void> voidStar = bytes.cast<ffi.Void>();
    init(encodedConfig.length, voidStar);
    malloc.free(voidStar);

    registerHandler(
        ffi.Pointer.fromFunction<_InputHandlerCallback>(_inputHandler));
    registerEventHandler(
        ffi.Pointer.fromFunction<_InputHandlerCallback>(_eventHandler));
  }

  void halt() {
    final _HaltFuncDart halt =
        _crustLib.lookup<ffi.NativeFunction<_HaltFunc>>('halt').asFunction();
    halt();
  }

  void run() {
    final _RunFuncDart run =
        _crustLib.lookup<ffi.NativeFunction<_RunFunc>>('run').asFunction();
    run();
  }

  /// Executes an [Action] in crust.
  ///
  /// Returns the entity id created, if any.
  int execute(Action action) {
    final encodedAction = action.writeToBuffer();
    final ffi.Pointer<ffi.Uint8> bytes =
        malloc.allocate<ffi.Uint8>(encodedAction.length);
    for (var i = 0; i < encodedAction.length; i++) {
      bytes.elementAt(i).value = encodedAction[i];
    }
    final ffi.Pointer<ffi.Void> voidStar = bytes.cast<ffi.Void>();
    final nodeId = _execute(encodedAction.length, voidStar);
    malloc.free(voidStar);

    return nodeId;
  }
}

typedef _InitFunc = ffi.Void Function(ffi.Int64 len, ffi.Pointer<ffi.Void>);
typedef _InitFuncDart = void Function(int len, ffi.Pointer<ffi.Void>);

typedef _HaltFunc = ffi.Void Function();
typedef _HaltFuncDart = void Function();

typedef _RunFunc = ffi.Void Function();
typedef _RunFuncDart = void Function();

typedef _ExecFunc = ffi.Uint32 Function(ffi.Int64 len, ffi.Pointer<ffi.Void>);
typedef _ExecFuncDart = int Function(int len, ffi.Pointer<ffi.Void>);

typedef _InputHandlerCallback = ffi.Void Function(
    ffi.Uint64 len, ffi.Pointer<ffi.Uint8>);
typedef _RegisterInputHandlerFunc = ffi.Uint32 Function(
    ffi.Pointer<ffi.NativeFunction<_InputHandlerCallback>>);
typedef _RegisterInputHandlerFuncDart = int Function(
    ffi.Pointer<ffi.NativeFunction<_InputHandlerCallback>>);

void _inputHandler(int len, ffi.Pointer<ffi.Uint8> ptr) {
  final event = UserInput()..mergeFromBuffer(ptr.asTypedList(len));
  inputManager.handle(event);
}

typedef _EventHandlerCallback = ffi.Void Function(
    ffi.Uint64 len, ffi.Pointer<ffi.Uint8>);
typedef _RegisterEventHandlerFunc = ffi.Uint32 Function(
    ffi.Pointer<ffi.NativeFunction<_EventHandlerCallback>>);
typedef _RegisterEventHandlerFuncDart = int Function(
    ffi.Pointer<ffi.NativeFunction<_EventHandlerCallback>>);

void _eventHandler(int len, ffi.Pointer<ffi.Uint8> ptr) {
  final event = Event()..mergeFromBuffer(ptr.asTypedList(len));
  eventManager.handle(event);
}

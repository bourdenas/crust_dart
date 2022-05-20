import 'dart:ffi' as ffi;

import 'package:crust_dart/src/proto/action.pb.dart';
import 'package:ffi/ffi.dart';

final crust = Crust();

class Crust {
  late ffi.DynamicLibrary _crustLib;
  late _ExecFuncDart _execute;

  void init(String libPath, String assetsPath) {
    _crustLib = ffi.DynamicLibrary.open("$libPath/crust_lib.dll");

    final _InitFuncDart init =
        _crustLib.lookup<ffi.NativeFunction<_InitFunc>>('init').asFunction();

    _execute =
        _crustLib.lookup<ffi.NativeFunction<_ExecFunc>>('execute').asFunction();

    final ffi.Pointer<Utf8> assetsPathCstr = assetsPath.toNativeUtf8();
    init(assetsPathCstr);
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

typedef _InitFunc = ffi.Void Function(ffi.Pointer<Utf8>);
typedef _InitFuncDart = void Function(ffi.Pointer<Utf8>);

typedef _HaltFunc = ffi.Void Function();
typedef _HaltFuncDart = void Function();

typedef _RunFunc = ffi.Void Function();
typedef _RunFuncDart = void Function();

typedef _ExecFunc = ffi.Uint32 Function(ffi.Int64 len, ffi.Pointer<ffi.Void>);
typedef _ExecFuncDart = int Function(int len, ffi.Pointer<ffi.Void>);

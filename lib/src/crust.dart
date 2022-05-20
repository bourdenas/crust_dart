import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

class Crust {
  late ffi.DynamicLibrary _crustLib;

  void init(String libPath, String assetsPath) {
    _crustLib = ffi.DynamicLibrary.open("$libPath/crust_lib.dll");

    final _InitFuncDart init =
        _crustLib.lookup<ffi.NativeFunction<_InitFunc>>('init').asFunction();
    final ffi.Pointer<Utf8> assetsPathCstr = assetsPath.toNativeUtf8();
    init(assetsPathCstr);
  }

  void halt() {
    final _HaltFuncDart halt =
        _crustLib.lookup<ffi.NativeFunction<_HaltFunc>>('halt').asFunction();
    halt();
  }
}

typedef _InitFunc = ffi.Void Function(ffi.Pointer<Utf8>);
typedef _InitFuncDart = void Function(ffi.Pointer<Utf8>);

typedef _HaltFunc = ffi.Void Function();
typedef _HaltFuncDart = void Function();

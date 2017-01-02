library legion.toolchains.clang;

import "dart:async";

import "package:legion/api.dart";
import "package:legion/utils.dart";

import "generic_compiler.dart";

const Map<String, String> clangTargetMap = const <String, String>{
  "linux-x64": "x86_64-linux-eabi",
  "linux-x86": "x86-linux-eabi",
  "linux-arm": "arm-linux-eabi",
  "linux-armv7a": "armv7a-linux-eabi",
  "linux-armv7m": "armv7m-linux-aebi",
  "mac-x64": "x86_64-apple-darwin-eabi",
  "mac-x86": "x86-apple-darwin-eabi"
};

class ClangHelper extends GenericCompilerHelper {
  ClangHelper(String path) : super(path);
}

class ClangToolchain extends GenericToolchain {
  ClangToolchain(String target, ClangHelper compiler) :
      super(target, compiler, "clang", "clang++");
}

class ClangToolchainProvider extends ToolchainProvider {
  static final String defaultClangPath = findExecutableSync("clang");

  final String path;

  ClangToolchainProvider(this.path);

  @override
  Future<String> getProviderId() async => "clang";

  @override
  Future<String> getProviderDescription() async {
    return "Clang (${path})";
  }

  @override
  Future<Toolchain> getToolchain(String target, Configuration config) async {
    var clang = new ClangHelper(path);

    return new ClangToolchain(target, clang);
  }

  @override
  Future<bool> isTargetSupported(String target, Configuration config) async {
    if (path == null) {
      return false;
    }

    var clang = new ClangHelper(path);
    var targets = await clang.getTargetNames();

    return targets.contains(target);
  }

  @override
  Future<List<String>> listBasicTargets() async {
    if (path == null) {
      return const <String>[];
    }

    var clang = new ClangHelper(path);
    var targets = await clang.getTargetNames(basic: true);
    return targets;
  }

  Future<bool> isValidCompiler() async {
    var clang = new ClangHelper(path);

    try {
      await clang.getVersion();
      return true;
    } catch (e) {
      return false;
    }
  }
}

library legion.builder;

import "dart:async";
import "dart:io";

import "api.dart";
import "storage.dart";
import "utils.dart";

import "src/builders/cmake.dart" as CMake;
import "src/toolchains/crosstool.dart" as CrossTool;
import "src/toolchains/gcc.dart" as Gcc;
import "src/toolchains/clang.dart" as Clang;

part "src/builder/stage.dart";
part "src/builder/cycle.dart";
part "src/builder/toolchains.dart";

final List<BuilderProvider> builderProviders = <BuilderProvider>[
  new CMake.CMakeBuilderProvider()
];

final List<ToolchainProvider> toolchainProviders = <ToolchainProvider>[
  new Gcc.GccToolchainProvider(Gcc.GccToolchainProvider.defaultGccPath),
  new Clang.ClangToolchainProvider(Clang.ClangToolchainProvider.defaultClangPath),
  new CrossTool.CrossToolToolchainProvider()
];

class BuildStageExecution {
  final BuildStage stage;
  final List<String> extraArguments;
  final List<String> targets;

  BuildStageExecution(this.stage, this.targets, this.extraArguments);
}

executeBuildStages(Directory directory, List<BuildStageExecution> executions) async {
  var project = new Project(directory);
  await project.init();

  for (var execution in executions) {
    var cycle = new BuildCycle(
      project,
      execution.stage,
      execution.targets,
      execution.extraArguments
    );

    await cycle.run();
  }
}

Future<ToolchainProvider> resolveToolchainProvider(String targetName, [StorageContainer config]) async {
  if (config == null) {
    config = new MockStorageContainer();
  }

  var providers = new List<ToolchainProvider>.from(await loadCustomToolchains());
  providers.addAll(toolchainProviders);
  for (var provider in providers) {
    var providerName  = await provider.getProviderId();

    if (targetName.startsWith("${providerName}:")) {
      targetName = targetName.substring("${providerName}:".length);
    }

    if (await provider.isTargetSupported(targetName, config)) {
      return provider;
    }
  }

  return null;
}

Future<Toolchain> resolveToolchain(String targetName, [StorageContainer config]) async {
  if (config == null) {
    config = new MockStorageContainer();
  }

  var provider = await resolveToolchainProvider(targetName, config);

  if (provider != null) {
    return await provider.getToolchain(targetName, config);
  } else {
    return null;
  }
}
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasus_client/app/app_state.dart';
import 'package:pasus_client/core/local_core/local_core_client.dart';
import 'package:pasus_client/core/scanning/scan_target_service.dart';
import 'package:pasus_protocol/pasus_protocol.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('quick scan can run while cloud is disabled', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final target = Directory.systemTemp.createTempSync('pasus-offline-');
    addTearDown(() => target.deleteSync(recursive: true));
    final localCore = _FakeLocalCoreClient();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        localCoreClientProvider.overrideWithValue(localCore),
        scanTargetServiceProvider.overrideWithValue(
          _FakeScanTargetService([target.path]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(pasusControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.runQuickScan();

    final state = container.read(pasusControllerProvider);
    expect(state.cloudStatus, CloudStatus.disabled);
    expect(state.scanStatus, ScanStatus.clean);
    expect(localCore.scanCalls, 1);
  });

  test('full scan can run without selecting a path', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final root = Directory.systemTemp.createTempSync('pasus-full-offline-');
    addTearDown(() => root.deleteSync(recursive: true));
    final localCore = _FakeLocalCoreClient();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        localCoreClientProvider.overrideWithValue(localCore),
        scanTargetServiceProvider.overrideWithValue(
          _FakeScanTargetService([root.path]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(pasusControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.runFullScan();

    expect(
      container.read(pasusControllerProvider).scanStatus,
      ScanStatus.clean,
    );
    expect(localCore.lastKind, ScanKind.full);
  });
}

class _FakeScanTargetService extends ScanTargetService {
  const _FakeScanTargetService(this.paths);

  final List<String> paths;

  @override
  List<String> quickScanTargets({Map<String, String>? environment}) => paths;

  @override
  List<String> fullScanRoots({Map<String, String>? environment}) => paths;
}

class _FakeLocalCoreClient extends LocalCoreClient {
  int scanCalls = 0;
  ScanKind? lastKind;

  @override
  bool get isDesktop => true;

  @override
  Future<MalwareEngineStatus> health() async => MalwareEngineStatus.available;

  @override
  Future<ScanReport> scanPaths(
    List<String> paths, {
    required ScanKind kind,
    required ScanActionMode actionMode,
    void Function(ScanProgress progress)? onProgress,
  }) async {
    scanCalls += 1;
    lastKind = kind;
    onProgress?.call(
      ScanProgress(
        jobId: 'test',
        scanType: kind,
        status: ScanJobStatus.running,
        filesScanned: 0,
        foldersScanned: 1,
        bytesScanned: 0,
        threatsFound: 0,
        suspiciousFound: 0,
        skippedFiles: 0,
        permissionDeniedCount: 0,
        startedAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        elapsedSeconds: 0,
      ),
    );
    return ScanReport(
      status: ScanStatus.clean,
      kind: kind,
      actionMode: actionMode,
      filesScanned: 0,
      foldersScanned: 1,
      bytesScanned: 0,
      threatsFound: 0,
      suspiciousFound: 0,
      skippedFiles: 0,
      elapsedMs: 1,
      threats: const [],
    );
  }
}

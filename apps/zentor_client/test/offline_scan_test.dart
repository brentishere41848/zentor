import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zentor_client/app/app_state.dart';
import 'package:zentor_client/core/local_core/local_core_client.dart';
import 'package:zentor_client/core/scanning/scan_target_service.dart';
import 'package:zentor_protocol/zentor_protocol.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('quick scan can run while cloud is disabled', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final target = Directory.systemTemp.createTempSync('zentor-offline-');
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

    final controller = container.read(zentorControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.runQuickScan();

    final state = container.read(zentorControllerProvider);
    expect(state.cloudStatus, CloudStatus.disabled);
    expect(state.scanStatus, ScanStatus.clean);
    expect(localCore.scanCalls, 1);
  });

  test('full scan can run without selecting a path', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final root = Directory.systemTemp.createTempSync('zentor-full-offline-');
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

    final controller = container.read(zentorControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.runFullScan();

    expect(
      container.read(zentorControllerProvider).scanStatus,
      ScanStatus.clean,
    );
    expect(localCore.lastKind, ScanKind.full);
  });

  test(
    'start protection starts best-effort watcher for protected folders',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final target = Directory.systemTemp.createTempSync(
        'avorax-watch-folder-',
      );
      addTearDown(() => target.deleteSync(recursive: true));
      final localCore = _FakeLocalCoreClient(
        watcherState: RealtimeWatcherState(
          active: true,
          mode: 'userModeBestEffort',
          watchedPaths: [target.path],
        ),
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          localCoreClientProvider.overrideWithValue(localCore),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(zentorControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      await controller.selectDetectedApp(
        DetectedApp(
          appId: 'folder',
          displayName: 'Protected folder',
          path: target.path,
          source: 'test',
        ),
      );
      await controller.startProtection();

      final state = container.read(zentorControllerProvider);
      expect(localCore.watchCalls, 1);
      expect(localCore.lastWatchPaths, [target.path]);
      expect(state.realtimeWatcherMode, 'userModeBestEffort');
      expect(state.realtimeWatchedPaths, [target.path]);
      expect(state.protectionStatus, ProtectionStatus.partiallyProtected);
      expect(state.errorMessage, isNull);
    },
  );

  test('stop protection stops watcher and clears watcher state', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final target = Directory.systemTemp.createTempSync('avorax-stop-watch-');
    addTearDown(() => target.deleteSync(recursive: true));
    final localCore = _FakeLocalCoreClient(
      watcherState: RealtimeWatcherState(
        active: true,
        mode: 'userModeBestEffort',
        watchedPaths: [target.path],
      ),
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        localCoreClientProvider.overrideWithValue(localCore),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(zentorControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.selectDetectedApp(
      DetectedApp(
        appId: 'folder',
        displayName: 'Protected folder',
        path: target.path,
        source: 'test',
      ),
    );
    await controller.startProtection();
    await controller.stopProtection();

    final state = container.read(zentorControllerProvider);
    expect(localCore.stopWatchCalls, 1);
    expect(state.realtimeWatcherMode, 'off');
    expect(state.realtimeWatchedPaths, isEmpty);
    expect(state.protectionStatus, ProtectionStatus.idle);
  });

  test('successful scan clears a stale engine error message', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final target = Directory.systemTemp.createTempSync('zentor-error-clear-');
    addTearDown(() => target.deleteSync(recursive: true));
    final localCore = _FakeLocalCoreClient(
      reports: [
        _scanReport(ScanStatus.engineUnavailable, ScanKind.quick),
        _scanReport(ScanStatus.clean, ScanKind.quick),
      ],
    );

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

    final controller = container.read(zentorControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.runQuickScan();
    expect(
      container.read(zentorControllerProvider).scanStatus,
      ScanStatus.engineUnavailable,
    );
    expect(container.read(zentorControllerProvider).errorMessage, isNotNull);

    await controller.runQuickScan();
    final state = container.read(zentorControllerProvider);
    expect(state.scanStatus, ScanStatus.clean);
    expect(state.errorMessage, isNull);
  });
}

class _FakeScanTargetService extends ScanTargetService {
  const _FakeScanTargetService(this.paths);

  final List<String> paths;

  @override
  List<String> quickScanTargets({
    Map<String, String>? environment,
    ScanPlatform? platform,
  }) => paths;

  @override
  List<String> fullScanRoots({
    Map<String, String>? environment,
    ScanPlatform? platform,
  }) => paths;
}

class _FakeLocalCoreClient extends LocalCoreClient {
  _FakeLocalCoreClient({
    List<ScanReport>? reports,
    this._watcherState = const RealtimeWatcherState(active: false, mode: 'off'),
  }) : _reports = List<ScanReport>.of(reports ?? const []);

  final List<ScanReport> _reports;
  final RealtimeWatcherState _watcherState;
  int scanCalls = 0;
  int watchCalls = 0;
  int stopWatchCalls = 0;
  List<String> lastWatchPaths = const [];
  ScanKind? lastKind;

  @override
  bool get isDesktop => true;

  @override
  Future<MalwareEngineStatus> health() async => MalwareEngineStatus.available;

  @override
  Future<LocalCoreHealth> healthSummary() async => const LocalCoreHealth(
    malwareEngineStatus: MalwareEngineStatus.available,
    nativeEngineStatus: 'ready',
    coreServiceStatus: 'running',
  );

  @override
  Future<bool> configureGuardMode(ProtectionMode mode) async => true;

  @override
  Future<RealtimeWatcherState> startWatch(List<String> paths) async {
    watchCalls += 1;
    lastWatchPaths = List<String>.of(paths);
    return _watcherState;
  }

  @override
  Future<RealtimeWatcherState> stopWatch() async {
    stopWatchCalls += 1;
    return const RealtimeWatcherState(active: false, mode: 'off');
  }

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
    return _reports.isNotEmpty
        ? _reports.removeAt(0)
        : _scanReport(ScanStatus.clean, kind, actionMode: actionMode);
  }
}

ScanReport _scanReport(
  ScanStatus status,
  ScanKind kind, {
  ScanActionMode actionMode = ScanActionMode.autoQuarantineConfirmedOnly,
}) {
  return ScanReport(
    status: status,
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

import 'dart:async';

import 'package:flutter_secure_file_storage/flutter_secure_file_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:log_to_secure_file/src/log_name_util.dart';

class SecureLogStorage {
  static const _prefix = 'log_to_secure_file';
  static const _logSeperator = '.';
  late final FlutterSecureFileStorage _storage;

  String? _logKey;

  final Duration logsExpireTime;
  final Duration logsExpireCheckInterval;
  final LogNameUtil _logNameUtil = LogNameUtil(_prefix);

  SecureLogStorage({
    FlutterSecureFileStorage? providedStorage,
    this.logsExpireCheckInterval = const Duration(days: 1),
    this.logsExpireTime = const Duration(days: 7),
  }) {
    _storage = providedStorage ?? FlutterSecureFileStorage(const FlutterSecureStorage());
    _init();
  }

  _init() {
    final now = DateTime.now();
    final logName = _logNameUtil.logNameFromDate(now);
    _logKey = logName;
    storeLogLine('=========================\n\nNew session started at ${now.toIso8601String()}\n\n=========================\n');
    _initTimer();
  }

  void _initTimer() {
    _deleteOldLogs();
    final pollingTime = logsExpireTime < logsExpireCheckInterval ? logsExpireTime : logsExpireCheckInterval;
    Timer.periodic(pollingTime, (timer) => _deleteOldLogs());
  }

  Future<List<DateTime>> availableDates() async {
    final keys = (await _storage.getAllKeys()).where((key) => key.startsWith(_prefix));
    return keys.map((key) => _logNameUtil.dateFromLogName(key)).whereType<DateTime>().toList();
  }

  Future<List<String>> getLogFromDate(DateTime date) async {
    final currentLogs = await _storage.read<String>(key: _logNameUtil.logNameFromDate(date));
    return currentLogs?.split(_logSeperator) ?? [];
  }

  Future<void> storeLogLine(String logLine) async {
    final logKey = _logKey;
    if (logKey == null) {
      throw ArgumentError('Init() should be called before using SecureLog_storage');
    }
    var currentLogs = await _storage.read<String>(key: logKey);
    var logArray = currentLogs?.split(_logSeperator) ?? [];
    logArray.add(logLine);
    var logString = logArray.join(_logSeperator);
    await _storage.write(key: logKey, value: logString);
  }

  Future<void> deleteLogs() async {
    final keys = (await _storage.getAllKeys()).where((key) => key.startsWith(_prefix));
    for (var element in keys) {
      await _storage.delete(key: element);
    }
  }

  Future<void> _deleteOldLogs() async {
    for (final date in await availableDates()) {
      final now = DateTime.now();
      if (now.difference(date) > logsExpireTime) {
        await _storage.delete(key: _logNameUtil.logNameFromDate(date));
      }
    }
  }
}

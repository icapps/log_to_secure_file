import 'package:flutter_secure_file_storage/flutter_secure_file_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_to_secure_file/log_to_secure_file.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'log_to_secure_file_test.mocks.dart';

@GenerateMocks([
  FlutterSecureFileStorage,
])
void main() {
  late MockFlutterSecureFileStorage flutterSecureFileStorage;
  late SecureLogStorage secureLogStorage;

  String getLogNameFromDate(DateTime date) => 'log_to_secure_file-logs-${date.year}_${date.month}_${date.day}';

  void verifyInit() {
    final now = DateTime.now();
    verify(flutterSecureFileStorage.read(key: getLogNameFromDate(now))).called(1);
    verify(flutterSecureFileStorage.write(
      key: getLogNameFromDate(now),
      value:
          'test.=========================\n\nNew session started at ${DateTime(now.year, now.month, now.day, now.hour, now.minute).toIso8601String()}\n\n=========================\n',
    )).called(1);
    verify(flutterSecureFileStorage.getAllKeys()).called(1);
  }

  setUp(() async {
    flutterSecureFileStorage = MockFlutterSecureFileStorage();
    secureLogStorage = SecureLogStorage(providedStorage: flutterSecureFileStorage);

    when(flutterSecureFileStorage.write<String>(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((_) => Future.value());
    when(flutterSecureFileStorage.read<String>(key: anyNamed('key'))).thenAnswer((_) => Future.value('test'));
    when(flutterSecureFileStorage.getAllKeys()).thenAnswer((_) => Future.value({}));

    // Verify init
    await secureLogStorage.init();
    verifyInit();
  });

  tearDown(() => secureLogStorage.dispose());

  test('Test basic logging', () async {
    final now = DateTime.now();
    await secureLogStorage.storeLogLine('This is a test');

    verify(flutterSecureFileStorage.read(key: getLogNameFromDate(now))).called(1);
    verify(flutterSecureFileStorage.write(key: getLogNameFromDate(now), value: 'test.This is a test')).called(1);

    final logLines = await secureLogStorage.getLogFromDate(now);

    expect(logLines[0], 'test');

    verify(flutterSecureFileStorage.read(key: getLogNameFromDate(now))).called(1);
    verifyNoMoreInteractions(flutterSecureFileStorage);
  });

  test('Test available dates', () async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    when(flutterSecureFileStorage.getAllKeys()).thenAnswer(
      (_) => Future.value({
        getLogNameFromDate(now),
        getLogNameFromDate(tomorrow),
      }),
    );
    final result = await secureLogStorage.availableDates();

    expect(result[0], DateTime(now.year, now.month, now.day));
    expect(result[1], DateTime(tomorrow.year, tomorrow.month, tomorrow.day));

    verify(flutterSecureFileStorage.getAllKeys()).called(1);
    verifyNoMoreInteractions(flutterSecureFileStorage);
  });

  test('Test deleting logs', () async {
    final now = DateTime.now();
    when(flutterSecureFileStorage.getAllKeys()).thenAnswer((_) => Future.value({getLogNameFromDate(now)}));

    await secureLogStorage.deleteLogs();

    verify(flutterSecureFileStorage.getAllKeys()).called(1);
    verify(flutterSecureFileStorage.delete(key: getLogNameFromDate(now))).called(1);
    verifyNoMoreInteractions(flutterSecureFileStorage);
  });

  test('Test auto deleting logs', () async {
    secureLogStorage.dispose();
    secureLogStorage = SecureLogStorage(
      providedStorage: flutterSecureFileStorage,
      logsExpireCheckInterval: const Duration(seconds: 1),
      logsExpireTime: const Duration(hours: 12),
    );
    await secureLogStorage.init();
    verifyInit();

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    when(flutterSecureFileStorage.getAllKeys()).thenAnswer((_) => Future.value({getLogNameFromDate(yesterday)}));

    await Future.delayed(const Duration(seconds: 1, milliseconds: 100));

    verify(flutterSecureFileStorage.getAllKeys()).called(1);
    verify(flutterSecureFileStorage.delete(key: getLogNameFromDate(yesterday))).called(1);
    verifyNoMoreInteractions(flutterSecureFileStorage);
  });
}

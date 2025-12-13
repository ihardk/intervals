import 'dart:ffi';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';

/// Setup sqlite3 for tests on Windows
void setupTestDatabase() {
  if (Platform.isWindows) {
    // Try to load sqlite3.dll from the flutter bundle
    open.overrideFor(OperatingSystem.windows, () {
      try {
        // Try common locations
        final possiblePaths = [
          'sqlite3.dll',
          'build/windows/runner/Debug/sqlite3.dll',
          'build/windows/runner/Release/sqlite3.dll',
        ];

        for (final path in possiblePaths) {
          if (File(path).existsSync()) {
            return DynamicLibrary.open(path);
          }
        }

        // Fall back to system sqlite3
        return DynamicLibrary.open('sqlite3.dll');
      } catch (e) {
        // If all else fails, try to use the default
        return DynamicLibrary.process();
      }
    });
  }
}

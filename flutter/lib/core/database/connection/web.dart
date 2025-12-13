// ignore_for_file: deprecated_member_use
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

LazyDatabase connect() {
  return LazyDatabase(() async {
    return WebDatabase.withStorage(DriftWebStorage.indexedDb('intervals_db'));
  });
}

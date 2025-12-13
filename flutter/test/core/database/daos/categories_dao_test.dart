import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:interval/core/database/app_database.dart';
import 'package:interval/core/database/daos/categories_dao.dart';

void main() {
  late AppDatabase database;
  late CategoriesDao categoriesDao;

  setUpAll(() async {
    // Initialize sqlite3 for tests on desktop platforms
    if (Platform.isWindows || Platform.isLinux) {
      applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
  });

  setUp(() {
    // Create in-memory database for testing
    database = AppDatabase.test(NativeDatabase.memory());
    categoriesDao = database.categoriesDao;
  });

  tearDown() async {
    await database.close();
  };

  group('CategoriesDao - Basic Operations', () {
    test('Given a category ID, When querying, Then should return category', () async {
      // Given - database has default categories
      const id = 'cat_work'; // Default category

      // When
      final category = await categoriesDao.getCategoryById(id);

      // Then
      expect(category, isNotNull);
      expect(category!.id, id);
      expect(category.name, 'Work');
      expect(category.isSystem, 1);
    });

    test('Given a non-existent ID, When querying, Then should return null', () async {
      // When
      final category = await categoriesDao.getCategoryById('non_existent');

      // Then
      expect(category, isNull);
    });

    test('Given a category name, When querying, Then should return category', () async {
      // Given
      const name = 'Work'; // Default category

      // When
      final category = await categoriesDao.getCategoryByName(name);

      // Then
      expect(category, isNotNull);
      expect(category!.name, name);
    });

    test('Given a new user category, When inserted, Then should be retrievable', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      final category = CategoriesCompanion.insert(
        id: 'cat_custom',
        name: 'Custom Category',
        color: const Value('#FF5733'),
        keywords: '[\"keyword1\", \"keyword2\"]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      );

      // When
      await categoriesDao.insertCategory(category);
      final retrieved = await categoriesDao.getCategoryById('cat_custom');

      // Then
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Custom Category');
      expect(retrieved.color, '#FF5733');
      expect(retrieved.isSystem, 0);
    });
  });

  group('CategoriesDao - Default Categories', () {
    test('Given database initialized, Then should have 5 default categories', () async {
      // When
      final systemCategories = await categoriesDao.getSystemCategories();

      // Then
      expect(systemCategories.length, 5);

      final categoryNames = systemCategories.map((c) => c.name).toList();
      expect(categoryNames.contains('Work'), true);
      expect(categoryNames.contains('Break'), true);
      expect(categoryNames.contains('Learning'), true);
      expect(categoryNames.contains('Social'), true);
      expect(categoryNames.contains('Distraction'), true);
    });

    test('Given default categories, Then should have correct colors', () async {
      // When
      final work = await categoriesDao.getCategoryByName('Work');
      final break_ = await categoriesDao.getCategoryByName('Break');
      final learning = await categoriesDao.getCategoryByName('Learning');
      final social = await categoriesDao.getCategoryByName('Social');
      final distraction = await categoriesDao.getCategoryByName('Distraction');

      // Then
      expect(work!.color, '#3B82F6'); // Blue
      expect(break_!.color, '#10B981'); // Green
      expect(learning!.color, '#8B5CF6'); // Purple
      expect(social!.color, '#F59E0B'); // Orange
      expect(distraction!.color, '#EF4444'); // Red
    });

    test('Given default categories, Then should have keywords for auto-categorization', () async {
      // When
      final work = await categoriesDao.getCategoryByName('Work');

      // Then
      expect(work!.keywords, isNotEmpty);
      expect(work.keywords, contains('coding'));
      expect(work.keywords, contains('work'));
    });
  });

  group('CategoriesDao - System vs User Categories', () {
    test('Given user category added, When getting user categories, Then should return only user categories', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_user1',
        name: 'User Category 1',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      // When
      final userCategories = await categoriesDao.getUserCategories();

      // Then
      expect(userCategories.length, 1);
      expect(userCategories.first.name, 'User Category 1');
      expect(userCategories.first.isSystem, 0);
    });

    test('Given mixed categories, When getting system categories, Then should return only system', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_user2',
        name: 'User Category 2',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      // When
      final systemCategories = await categoriesDao.getSystemCategories();

      // Then
      expect(systemCategories.length, 5); // 5 default system categories
      expect(systemCategories.every((c) => c.isSystem == 1), true);
    });

    test('Given mixed categories, When getting all, Then should return all', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_user3',
        name: 'User Category 3',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      // When
      final allCategories = await categoriesDao.getAllCategories();

      // Then
      expect(allCategories.length, 6); // 5 system + 1 user
    });
  });

  group('CategoriesDao - Update Operations', () {
    test('Given an existing category, When updated, Then changes should persist', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_update_test',
        name: 'Original Name',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      // When
      final original = await categoriesDao.getCategoryById('cat_update_test');
      final updated = original!.copyWith(
        name: 'Updated Name',
        color: const Value('#ABCDEF'),
      );
      await categoriesDao.updateCategory(updated);
      final retrieved = await categoriesDao.getCategoryById('cat_update_test');

      // Then
      expect(retrieved!.name, 'Updated Name');
      expect(retrieved.color, '#ABCDEF');
    });

    test('Given system category, When updated, Then should allow updates', () async {
      // Given - modify a system category
      final work = await categoriesDao.getCategoryByName('Work');

      // When
      final updated = work!.copyWith(color: const Value('#FFFFFF'));
      await categoriesDao.updateCategory(updated);
      final retrieved = await categoriesDao.getCategoryById(work.id);

      // Then
      expect(retrieved!.color, '#FFFFFF');
    });
  });

  group('CategoriesDao - Delete Operations', () {
    test('Given user category, When deleted, Then should be removed', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_delete_test',
        name: 'To Be Deleted',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      // When
      await categoriesDao.deleteCategory('cat_delete_test');
      final retrieved = await categoriesDao.getCategoryById('cat_delete_test');

      // Then
      expect(retrieved, isNull);
    });

    test('Given system category, When delete attempted, Then should NOT be deleted', () async {
      // Given
      const systemCategoryId = 'cat_work';

      // When
      final deleteCount = await categoriesDao.deleteCategory(systemCategoryId);
      final retrieved = await categoriesDao.getCategoryById(systemCategoryId);

      // Then
      expect(deleteCount, 0); // No rows deleted
      expect(retrieved, isNotNull); // Category still exists
    });
  });

  group('CategoriesDao - Count Operations', () {
    test('Given default categories, When counting, Then should return correct count', () async {
      // When
      final count = await categoriesDao.getCategoryCount();

      // Then
      expect(count, 5); // 5 default system categories
    });

    test('Given additional user categories, When counting, Then should include all', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_count1',
        name: 'Count Test 1',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_count2',
        name: 'Count Test 2',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      // When
      final count = await categoriesDao.getCategoryCount();

      // Then
      expect(count, 7); // 5 system + 2 user
    });
  });

  group('CategoriesDao - Stream Watchers', () {
    test('Given category stream, When category changes, Then stream should emit', () async {
      // Given
      const categoryId = 'cat_stream_test';
      final now = DateTime.now().millisecondsSinceEpoch;
      final stream = categoriesDao.watchCategory(categoryId);

      // Then
      expectLater(
        stream,
        emitsInOrder([
          isNull, // Initial state
          isNotNull, // After insert
          predicate<CategoryData>((c) => c.name == 'Updated Name'), // After update
        ]),
      );

      // When
      await Future.delayed(const Duration(milliseconds: 10));
      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: categoryId,
        name: 'Original Name',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      await Future.delayed(const Duration(milliseconds: 10));
      final category = (await categoriesDao.getCategoryById(categoryId))!;
      await categoriesDao.updateCategory(category.copyWith(name: 'Updated Name'));
    });

    test('Given all categories stream, When categories change, Then stream should emit', () async {
      // Given
      final initialCount = (await categoriesDao.getAllCategories()).length;
      final stream = categoriesDao.watchAllCategories();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Then
      expectLater(
        stream,
        emitsInOrder([
          hasLength(initialCount), // Initial state with defaults
          hasLength(initialCount + 1), // After insert
        ]),
      );

      // When
      await Future.delayed(const Duration(milliseconds: 10));
      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_watch_all',
        name: 'Watch All Test',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));
    });
  });

  group('CategoriesDao - Sorting', () {
    test('Given categories, When getting all, Then should be sorted by name', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_z',
        name: 'Zebra',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_a',
        name: 'Apple',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      // When
      final categories = await categoriesDao.getAllCategories();

      // Then - should be alphabetically sorted
      final userCategories = categories.where((c) => c.isSystem == 0).toList();
      expect(userCategories.first.name, 'Apple');
      expect(userCategories.last.name, 'Zebra');
    });
  });

  group('CategoriesDao - Keywords', () {
    test('Given category with keywords, When retrieved, Then keywords should be preserved', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      final keywords = '[\"test\", \"example\", \"demo\"]';

      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_keywords',
        name: 'Keywords Test',
        keywords: keywords,
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      // When
      final retrieved = await categoriesDao.getCategoryById('cat_keywords');

      // Then
      expect(retrieved!.keywords, keywords);
      expect(retrieved.keywords, contains('test'));
      expect(retrieved.keywords, contains('example'));
      expect(retrieved.keywords, contains('demo'));
    });

    test('Given empty keywords, When stored, Then should be preserved', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;

      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_empty_keywords',
        name: 'Empty Keywords',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      // When
      final retrieved = await categoriesDao.getCategoryById('cat_empty_keywords');

      // Then
      expect(retrieved!.keywords, '[]');
    });
  });

  group('CategoriesDao - Color Validation', () {
    test('Given category with color, When stored, Then should be preserved', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      const color = '#FF5733';

      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_color',
        name: 'Color Test',
        color: const Value(color),
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      // When
      final retrieved = await categoriesDao.getCategoryById('cat_color');

      // Then
      expect(retrieved!.color, color);
    });

    test('Given category without color, When stored, Then should be null', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;

      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_no_color',
        name: 'No Color',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      // When
      final retrieved = await categoriesDao.getCategoryById('cat_no_color');

      // Then
      expect(retrieved!.color, isNull);
    });
  });

  group('CategoriesDao - Timestamp Tracking', () {
    test('Given category created, When retrieved, Then should have timestamps', () async {
      // Given
      final beforeTime = DateTime.now().millisecondsSinceEpoch;
      final now = beforeTime;

      await categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: 'cat_timestamp',
        name: 'Timestamp Test',
        keywords: '[]',
        isSystem: const Value(0),
        createdAt: now,
        updatedAt: now,
      ));

      final afterTime = DateTime.now().millisecondsSinceEpoch;

      // When
      final retrieved = await categoriesDao.getCategoryById('cat_timestamp');

      // Then
      expect(retrieved!.createdAt, greaterThanOrEqualTo(beforeTime));
      expect(retrieved.createdAt, lessThanOrEqualTo(afterTime));
      expect(retrieved.updatedAt, greaterThanOrEqualTo(beforeTime));
      expect(retrieved.updatedAt, lessThanOrEqualTo(afterTime));
    });
  });
}

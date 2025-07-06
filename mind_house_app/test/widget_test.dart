// This is a basic Flutter widget test for the Mind House app.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:mind_house_app/main.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/services/information_service.dart';
import 'package:mind_house_app/services/tag_service.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Mind House app smoke test', (WidgetTester tester) async {
    // Create in-memory database for testing
    final database = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        // Create test database schema (simplified)
        await db.execute('''
          CREATE TABLE information (
            id TEXT PRIMARY KEY,
            content TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE tags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE NOT NULL,
            color TEXT,
            usage_count INTEGER DEFAULT 0
          )
        ''');
      },
    );

    final informationRepository = InformationRepository(database);
    final tagRepository = TagRepository(database);
    
    // Initialize services
    final tagService = TagService(tagRepository);
    final informationService = InformationService(
      informationRepository: informationRepository,
      tagRepository: tagRepository,
      tagService: tagService,
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(MindHouseApp(
      informationRepository: informationRepository,
      tagRepository: tagRepository,
      informationService: informationService,
      tagService: tagService,
    ));

    // Verify the app loads with proper navigation
    expect(find.text('Store Information'), findsOneWidget);
    expect(find.text('Store'), findsOneWidget);
    expect(find.text('Browse'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);

    await database.close();
  });
}

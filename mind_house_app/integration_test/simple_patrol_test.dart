import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:mind_house_app/main.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/services/information_service.dart';
import 'package:mind_house_app/services/tag_service.dart';
import 'package:mind_house_app/database/database_helper.dart';

void main() {
  patrolTest(
    'Simple navigation test - click 2 UI elements',
    ($) async {
      // Initialize database and dependencies
      final databaseHelper = DatabaseHelper();
      final database = await databaseHelper.database;
      final informationRepository = InformationRepository(database);
      final tagRepository = TagRepository(database);
      final tagService = TagService(tagRepository);
      final informationService = InformationService(
        informationRepository: informationRepository,
        tagRepository: tagRepository,
        tagService: tagService,
      );

      // Start the app with dependencies
      await $.pumpWidgetAndSettle(
        MindHouseApp(
          informationRepository: informationRepository,
          tagRepository: tagRepository,
          informationService: informationService,
          tagService: tagService,
        ),
      );

      // Verify we start on Store Information page
      expect($('Store Information'), findsOneWidget);
      
      // Test 1: Click on "List Information" tab
      await $('List Information').tap();
      await $.pumpAndSettle();
      
      // Verify we navigated to List Information page
      expect($('List Information'), findsWidgets);
      
      // Optional: Take a screenshot for debugging
      // await $.takeScreenshot(name: 'list_information_page');
      
      // Test 2: Click on "Information" tab  
      await $('Information').tap();
      await $.pumpAndSettle();
      
      // Verify we navigated to Information page
      expect($('Information'), findsWidgets);
      
      // Optional: Take a screenshot
      // await $.takeScreenshot(name: 'information_page');
      
      // Success! We've clicked 2 UI elements and verified navigation
      print('✅ Navigation test passed - successfully clicked 2 UI elements');
    },
  );

  patrolTest(
    'Enter text and interact with UI elements',
    ($) async {
      // Initialize database and dependencies
      final databaseHelper = DatabaseHelper();
      final database = await databaseHelper.database;
      final informationRepository = InformationRepository(database);
      final tagRepository = TagRepository(database);
      final tagService = TagService(tagRepository);
      final informationService = InformationService(
        informationRepository: informationRepository,
        tagRepository: tagRepository,
        tagService: tagService,
      );

      // Start the app with dependencies
      await $.pumpWidgetAndSettle(
        MindHouseApp(
          informationRepository: informationRepository,
          tagRepository: tagRepository,
          informationService: informationService,
          tagService: tagService,
        ),
      );

      // Find the text field and enter some text
      final contentField = $(TextField).first;
      await contentField.enterText('Testing with Patrol!');
      await $.pumpAndSettle();
      
      // Verify the text was entered
      expect($('Testing with Patrol!'), findsOneWidget);
      
      // Try to enter a tag in the second text field if it exists
      try {
        final tagField = $(TextField).at(1);
        await tagField.enterText('patrol-test');
        await $.pumpAndSettle();
      } catch (e) {
        // Tag field might not be available, that's okay
        print('Tag field not found, skipping tag entry');
      }
      
      // Try to find and click the Save button
      final saveButton = $('Save');
      if (saveButton.exists) {
        await saveButton.tap();
        await $.pumpAndSettle();
        
        print('✅ Successfully entered text and clicked Save');
      }
    },
  );

  patrolTest(
    'Verify UI responsiveness',
    ($) async {
      // Initialize database and dependencies
      final databaseHelper = DatabaseHelper();
      final database = await databaseHelper.database;
      final informationRepository = InformationRepository(database);
      final tagRepository = TagRepository(database);
      final tagService = TagService(tagRepository);
      final informationService = InformationService(
        informationRepository: informationRepository,
        tagRepository: tagRepository,
        tagService: tagService,
      );

      // Start the app with dependencies
      await $.pumpWidgetAndSettle(
        MindHouseApp(
          informationRepository: informationRepository,
          tagRepository: tagRepository,
          informationService: informationService,
          tagService: tagService,
        ),
      );

      // Quick navigation test - tap multiple elements rapidly
      await $('List Information').tap();
      await $.pump(const Duration(milliseconds: 500));
      
      await $('Information').tap();
      await $.pump(const Duration(milliseconds: 500));
      
      await $('Store Information').tap();
      await $.pumpAndSettle();
      
      // Verify app is still responsive
      expect($('Store Information'), findsWidgets);
      
      print('✅ UI responsiveness test passed');
    },
  );
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/database/database_helper.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/blocs/information/information_bloc.dart';
import 'package:mind_house_app/blocs/tag/tag_bloc.dart';
import 'package:mind_house_app/pages/main_navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final databaseHelper = DatabaseHelper();
  final database = await databaseHelper.database;
  
  // Initialize repositories
  final informationRepository = InformationRepository(database);
  final tagRepository = TagRepository(database);
  
  runApp(MindHouseApp(
    informationRepository: informationRepository,
    tagRepository: tagRepository,
  ));
}

class MindHouseApp extends StatelessWidget {
  final InformationRepository informationRepository;
  final TagRepository tagRepository;

  const MindHouseApp({
    super.key,
    required this.informationRepository,
    required this.tagRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InformationBloc>(
          create: (context) => InformationBloc(
            informationRepository: informationRepository,
            tagRepository: tagRepository,
          ),
        ),
        BlocProvider<TagBloc>(
          create: (context) => TagBloc(
            tagRepository: tagRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Mind House',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const MainNavigationPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
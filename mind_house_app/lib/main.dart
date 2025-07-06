import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/database/database_helper.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/blocs/information/information_bloc.dart';
import 'package:mind_house_app/blocs/tag/tag_bloc.dart';
import 'package:mind_house_app/blocs/tag_suggestion/tag_suggestion_bloc.dart';
import 'package:mind_house_app/pages/main_navigation_page.dart';
import 'package:mind_house_app/navigation/app_router.dart';
import 'package:mind_house_app/widgets/navigation_wrapper.dart';
import 'package:mind_house_app/services/information_service.dart';
import 'package:mind_house_app/services/tag_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final databaseHelper = DatabaseHelper();
  final database = await databaseHelper.database;
  
  // Initialize repositories
  final informationRepository = InformationRepository(database);
  final tagRepository = TagRepository(database);
  
  // Initialize services
  final tagService = TagService(tagRepository);
  final informationService = InformationService(
    informationRepository: informationRepository,
    tagRepository: tagRepository,
    tagService: tagService,
  );
  
  runApp(MindHouseApp(
    informationRepository: informationRepository,
    tagRepository: tagRepository,
    informationService: informationService,
    tagService: tagService,
  ));
}

class MindHouseApp extends StatelessWidget {
  final InformationRepository informationRepository;
  final TagRepository tagRepository;
  final InformationService informationService;
  final TagService tagService;

  const MindHouseApp({
    super.key,
    required this.informationRepository,
    required this.tagRepository,
    required this.informationService,
    required this.tagService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InformationBloc>(
          create: (context) => InformationBloc(
            informationRepository: informationRepository,
            tagRepository: tagRepository,
            informationService: informationService,
            tagService: tagService,
          ),
        ),
        BlocProvider<TagBloc>(
          create: (context) => TagBloc(
            tagRepository: tagRepository,
          ),
        ),
        BlocProvider<TagSuggestionBloc>(
          create: (context) => TagSuggestionBloc(
            tagRepository: tagRepository,
            tagService: tagService,
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
        navigatorKey: AppNavigator.navigatorKey,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.home,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return NavigationWrapper(
            onBackgroundReturn: () {
              // Refresh data when returning from background
              // This could trigger a refresh of the current page
            },
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
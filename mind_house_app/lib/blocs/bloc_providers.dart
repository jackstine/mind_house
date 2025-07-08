import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/interfaces/information_repository_interface.dart';
import '../repositories/interfaces/tag_repository_interface.dart';

class BlocProvidersWidget extends StatelessWidget {
  final Widget child;
  final InformationRepositoryInterface informationRepository;
  final TagRepositoryInterface tagRepository;

  const BlocProvidersWidget({
    super.key,
    required this.child,
    required this.informationRepository,
    required this.tagRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<InformationRepositoryInterface>.value(
          value: informationRepository,
        ),
        RepositoryProvider<TagRepositoryInterface>.value(
          value: tagRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // BLoC providers will be added here when specific BLoCs are created
          // For now, we just provide the repositories
        ],
        child: child,
      ),
    );
  }
}

class BlocProvidersList {
  static List<BlocProvider> getProviders({
    required InformationRepositoryInterface informationRepository,
    required TagRepositoryInterface tagRepository,
  }) {
    return [
      // Specific BLoC providers will be added here when BLoCs are implemented
      // Example:
      // BlocProvider<InformationBloc>(
      //   create: (context) => InformationBloc(informationRepository),
      // ),
      // BlocProvider<TagBloc>(
      //   create: (context) => TagBloc(tagRepository),
      // ),
    ];
  }
}
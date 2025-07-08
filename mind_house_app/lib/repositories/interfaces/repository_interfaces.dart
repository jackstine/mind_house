/// Repository interface exports for easy importing
/// 
/// This file provides a single entry point for importing all repository interfaces,
/// making it easier to work with dependency injection and testing scenarios.
/// 
/// Usage:
/// ```dart
/// import 'package:mind_house_app/repositories/interfaces/repository_interfaces.dart';
/// 
/// // Now you can use:
/// IInformationRepository infoRepo = InformationRepository();
/// ITagRepository tagRepo = TagRepository();
/// ```

export 'information_repository_interface.dart';
export 'tag_repository_interface.dart';
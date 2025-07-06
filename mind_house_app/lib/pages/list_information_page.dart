import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/information/information_bloc.dart';
import 'package:mind_house_app/blocs/information/information_event.dart';
import 'package:mind_house_app/blocs/information/information_state.dart';
import 'package:mind_house_app/blocs/tag/tag_bloc.dart';
import 'package:mind_house_app/blocs/tag/tag_event.dart';
import 'package:mind_house_app/blocs/tag/tag_state.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/widgets/information_card.dart';
import 'package:mind_house_app/widgets/tag_filter.dart';
import 'package:mind_house_app/widgets/search_button.dart' as custom;
import 'package:mind_house_app/widgets/empty_state.dart';
import 'package:mind_house_app/widgets/loading_indicator.dart';

class ListInformationPage extends StatefulWidget {
  const ListInformationPage({super.key});

  @override
  State<ListInformationPage> createState() => _ListInformationPageState();
}

class _ListInformationPageState extends State<ListInformationPage> {
  final _searchController = TextEditingController();
  final List<String> _selectedTagFilters = [];

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<InformationBloc>().add(LoadAllInformation());
    context.read<TagBloc>().add(LoadMostUsedTags(limit: 20));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchInformation() {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      context.read<InformationBloc>().add(SearchInformation(searchTerm));
    } else {
      context.read<InformationBloc>().add(LoadAllInformation());
    }
  }

  void _toggleTagFilter(String tagName) {
    setState(() {
      if (_selectedTagFilters.contains(tagName)) {
        _selectedTagFilters.remove(tagName);
      } else {
        _selectedTagFilters.add(tagName);
      }
    });
    
    // For now, just reload all information since we need tag IDs
    // TODO: Implement proper tag filtering with tag IDs
    context.read<InformationBloc>().add(LoadAllInformation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Information'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: custom.SearchBar(
              controller: _searchController,
              hintText: 'Search information...',
              onSubmitted: (value) => _searchInformation(),
              onSearchPressed: _searchInformation,
              onClearPressed: () {
                context.read<InformationBloc>().add(LoadAllInformation());
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tag filter section
          TagFilter(
            selectedTags: _selectedTagFilters,
            onTagsChanged: (tags) {
              setState(() {
                _selectedTagFilters.clear();
                _selectedTagFilters.addAll(tags);
              });
              // For now, just reload all information since we need tag IDs
              // TODO: Implement proper tag filtering with tag IDs
              context.read<InformationBloc>().add(LoadAllInformation());
            },
          ),
          
          // Information list
          Expanded(
            child: BlocBuilder<InformationBloc, InformationState>(
              builder: (context, state) {
                if (state is InformationLoading) {
                  return const LoadingIndicator(message: 'Loading information...');
                } else if (state is InformationLoaded) {
                  if (state.information.isEmpty) {
                    return _selectedTagFilters.isNotEmpty 
                      ? EmptySearchState(
                          query: 'filtered results',
                          onClearSearch: () {
                            setState(() {
                              _selectedTagFilters.clear();
                            });
                            context.read<InformationBloc>().add(LoadAllInformation());
                          },
                        )
                      : EmptyInformationState(
                          onCreateFirst: () {
                            // Navigate to Store tab
                            DefaultTabController.of(context)?.animateTo(0);
                          },
                        );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.information.length,
                    itemBuilder: (context, index) {
                      final information = state.information[index];
                      return InformationCard(
                        information: information,
                        onTap: () {
                          // Navigate to information detail view
                          // TODO: Implement navigation to detail view
                        },
                        onEdit: () {
                          // TODO: Implement edit functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit functionality coming soon!')),
                          );
                        },
                        onDelete: () {
                          context.read<InformationBloc>().add(
                            DeleteInformation(information.id),
                          );
                        },
                      );
                    },
                  );
                } else if (state is InformationError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading information',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<InformationBloc>().add(LoadAllInformation());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                return const Center(child: Text('Start browsing your information'));
              },
            ),
          ),
        ],
      ),
    );
  }
}


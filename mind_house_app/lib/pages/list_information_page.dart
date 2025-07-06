import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/information/information_bloc.dart';
import 'package:mind_house_app/blocs/information/information_event.dart';
import 'package:mind_house_app/blocs/information/information_state.dart';
import 'package:mind_house_app/blocs/tag/tag_bloc.dart';
import 'package:mind_house_app/blocs/tag/tag_event.dart';
import 'package:mind_house_app/blocs/tag/tag_state.dart';
import 'package:mind_house_app/models/information.dart';

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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search information...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchInformation(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _searchInformation,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tag filter section
          BlocBuilder<TagBloc, TagState>(
            builder: (context, state) {
              if (state is TagLoaded) {
                return Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.tags.length,
                    itemBuilder: (context, index) {
                      final tag = state.tags[index];
                      final isSelected = _selectedTagFilters.contains(tag.name);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: FilterChip(
                          label: Text(tag.name),
                          selected: isSelected,
                          onSelected: (_) => _toggleTagFilter(tag.name),
                          backgroundColor: tag.color != null 
                            ? Color(int.parse(tag.color!, radix: 16) | 0xFF000000)
                            : null,
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox(height: 60);
            },
          ),
          
          // Information list
          Expanded(
            child: BlocBuilder<InformationBloc, InformationState>(
              builder: (context, state) {
                if (state is InformationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is InformationLoaded) {
                  if (state.information.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No information found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start by adding some information in the Store tab',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.information.length,
                    itemBuilder: (context, index) {
                      final information = state.information[index];
                      return _InformationCard(information: information);
                    },
                  );
                } else if (state is InformationError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error loading information',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(state.message),
                        SizedBox(height: 16),
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

class _InformationCard extends StatelessWidget {
  final Information information;

  const _InformationCard({required this.information});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              information.content,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created: ${_formatDate(information.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (information.createdAt != information.updatedAt)
                  Text(
                    'Updated: ${_formatDate(information.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
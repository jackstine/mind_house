import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/information/information_bloc.dart';
import 'package:mind_house_app/blocs/information/information_event.dart';
import 'package:mind_house_app/blocs/information/information_state.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/widgets/information_card.dart';
import 'package:mind_house_app/widgets/empty_state.dart';
import 'package:mind_house_app/widgets/loading_indicator.dart';
import 'package:mind_house_app/widgets/content_input.dart';

class InformationPage extends StatefulWidget {
  final String? informationId;
  
  const InformationPage({super.key, this.informationId});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  Information? _currentInformation;

  @override
  void initState() {
    super.initState();
    if (widget.informationId != null) {
      context.read<InformationBloc>().add(LoadInformationById(widget.informationId!));
    }
  }

  void _showInformationSelector() {
    context.read<InformationBloc>().add(LoadAllInformation());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            AppBar(
              title: const Text('Select Information'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Expanded(
              child: BlocConsumer<InformationBloc, InformationState>(
                listener: (context, state) {
                  if (state is InformationLoaded && state.information.isNotEmpty) {
                    // Keep the modal open to show the list
                  }
                },
                builder: (context, state) {
                  if (state is InformationLoading) {
                    return const LoadingIndicator(message: 'Loading information...');
                  } else if (state is InformationLoaded) {
                    if (state.information.isEmpty) {
                      return EmptyInformationState(
                        onCreateFirst: () {
                          Navigator.pop(context);
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
                          showActions: false,
                          onTap: () {
                            setState(() {
                              _currentInformation = information;
                            });
                            Navigator.pop(context);
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
                          SizedBox(height: 16),
                          Text(
                            'Error loading information',
                            style: TextStyle(fontSize: 18, color: Colors.red),
                          ),
                          Text(state.message),
                        ],
                      ),
                    );
                  }
                  
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Information'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: _showInformationSelector,
            icon: const Icon(Icons.list),
            tooltip: 'Select Information',
          ),
        ],
      ),
      body: BlocListener<InformationBloc, InformationState>(
        listener: (context, state) {
          if (state is InformationSingleLoaded) {
            setState(() {
              _currentInformation = state.information;
            });
          }
        },
        child: _currentInformation != null
            ? _InformationDetailView(information: _currentInformation!)
            : _EmptyStateView(onSelectInformation: _showInformationSelector),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InformationDetailView extends StatelessWidget {
  final Information information;

  const _InformationDetailView({required this.information});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Information content
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      information.content,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Information metadata
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'ID',
                    value: information.id,
                    context: context,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Created',
                    value: _formatDate(information.createdAt),
                    context: context,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Updated', 
                    value: _formatDate(information.updatedAt),
                    context: context,
                  ),
                  if (information.createdAt != information.updatedAt) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Modified',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Future implementation: Navigate to edit mode
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit functionality coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Future implementation: Share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share functionality coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final VoidCallback onSelectInformation;

  const _EmptyStateView({required this.onSelectInformation});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No information selected',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select an information item to view its details',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onSelectInformation,
            icon: const Icon(Icons.list),
            label: const Text('Browse Information'),
          ),
        ],
      ),
    );
  }
}
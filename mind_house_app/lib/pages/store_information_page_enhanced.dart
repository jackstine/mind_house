import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/information/information_bloc.dart';
import 'package:mind_house_app/blocs/information/information_event.dart';
import 'package:mind_house_app/blocs/information/information_state.dart';
import 'package:mind_house_app/widgets/content_input.dart';
import 'package:mind_house_app/widgets/tag_chip.dart';
import 'package:mind_house_app/widgets/save_button.dart';
import 'package:mind_house_app/models/tag.dart';

class EnhancedStoreInformationPage extends StatefulWidget {
  const EnhancedStoreInformationPage({super.key});

  @override
  State<EnhancedStoreInformationPage> createState() => _EnhancedStoreInformationPageState();
}

class _EnhancedStoreInformationPageState extends State<EnhancedStoreInformationPage> {
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _selectedTags = [];
  SaveButtonState _saveButtonState = SaveButtonState.idle;

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _saveInformation() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some content before saving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _saveButtonState = SaveButtonState.loading;
    });

    context.read<InformationBloc>().add(
      CreateInformation(
        content: _contentController.text.trim(),
        tagNames: List.from(_selectedTags),
      ),
    );
  }

  void _addTag(String tagName) {
    final tagText = tagName.trim();
    if (tagText.isNotEmpty && !_selectedTags.contains(tagText)) {
      setState(() {
        _selectedTags.add(tagText);
      });
    }
  }

  void _addTagFromInput() {
    _addTag(_tagController.text);
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InformationBloc, InformationState>(
      listener: (context, state) {
        if (state is InformationCreated) {
          setState(() {
            _saveButtonState = SaveButtonState.success;
          });
          
          // Clear form after successful save
          _contentController.clear();
          _selectedTags.clear();
          
          // Reset button state after animation
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _saveButtonState = SaveButtonState.idle;
              });
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Information saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is InformationError) {
          setState(() {
            _saveButtonState = SaveButtonState.error;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
          
          // Reset button state
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _saveButtonState = SaveButtonState.idle;
              });
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Store Information'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content input area
              Expanded(
                flex: 3,
                child: ContentInput(
                  controller: _contentController,
                  labelText: 'Information Content',
                  hintText: 'Enter your information here...',
                  expands: true,
                ),
              ),
              const SizedBox(height: 16),
              
              // Tag input area
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'Add a tag...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.tag),
                      ),
                      onSubmitted: (_) => _addTagFromInput(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addTagFromInput,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Selected tags display
              if (_selectedTags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _selectedTags.map((tagName) {
                    final tag = Tag(name: tagName);
                    return TagChip(
                      tag: tag,
                      showDeleteButton: true,
                      onDeleted: () => _removeTag(tagName),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 16),
              
              // Save button
              SaveButton(
                onPressed: _saveInformation,
                state: _saveButtonState,
                fullWidth: true,
                idleText: 'Save Information',
                loadingText: 'Saving...',
                successText: 'Saved!',
                errorText: 'Save Failed',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
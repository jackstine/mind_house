import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/information/information_bloc.dart';
import 'package:mind_house_app/blocs/information/information_event.dart';

class StoreInformationPage extends StatefulWidget {
  const StoreInformationPage({super.key});

  @override
  State<StoreInformationPage> createState() => _StoreInformationPageState();
}

class _StoreInformationPageState extends State<StoreInformationPage> {
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _selectedTags = [];

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _saveInformation() {
    if (_contentController.text.trim().isNotEmpty) {
      context.read<InformationBloc>().add(
        CreateInformation(
          content: _contentController.text.trim(),
          tagNames: List.from(_selectedTags),
        ),
      );
      
      // Clear form after saving
      _contentController.clear();
      _selectedTags.clear();
      setState(() {});
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Information saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _addTag() {
    final tagText = _tagController.text.trim();
    if (tagText.isNotEmpty && !_selectedTags.contains(tagText)) {
      setState(() {
        _selectedTags.add(tagText);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Text(
              'Information Content',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Enter your information here...',
                  border: OutlineInputBorder(),
                ),
                textAlignVertical: TextAlignVertical.top,
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
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTag,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Selected tags display
            if (_selectedTags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _selectedTags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 16),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _contentController.text.trim().isNotEmpty ? _saveInformation : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Information'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
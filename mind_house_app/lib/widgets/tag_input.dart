import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/tag_suggestion/tag_suggestion_bloc.dart';
import 'package:mind_house_app/blocs/tag_suggestion/tag_suggestion_event.dart';
import 'package:mind_house_app/blocs/tag_suggestion/tag_suggestion_state.dart';
import 'package:mind_house_app/widgets/tag_suggestions_list.dart';

class TagInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onTagAdded;
  final VoidCallback? onSubmitted;
  final bool showSuggestions;
  final EdgeInsetsGeometry? padding;

  const TagInput({
    super.key,
    this.controller,
    this.hintText = 'Add a tag...',
    this.onTagAdded,
    this.onSubmitted,
    this.showSuggestions = true,
    this.padding,
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.showSuggestions) {
      _showSuggestionsOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onTextChanged(String text) {
    if (widget.showSuggestions && text.isNotEmpty) {
      context.read<TagSuggestionBloc>().add(
        LoadTagSuggestions(prefix: text),
      );
      if (!_showSuggestions) {
        _showSuggestionsOverlay();
      }
    } else {
      context.read<TagSuggestionBloc>().add(ClearTagSuggestions());
      _removeOverlay();
    }
  }

  void _showSuggestionsOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32, // Account for padding
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60), // Position below the input
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: BlocBuilder<TagSuggestionBloc, TagSuggestionState>(
              builder: (context, state) {
                if (state is TagSuggestionLoaded && state.suggestions.isNotEmpty) {
                  return TagSuggestionsList(
                    suggestions: state.suggestions,
                    onTagSelected: (tagName) {
                      _controller.text = tagName;
                      widget.onTagAdded?.call(tagName);
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _showSuggestions = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _showSuggestions = false;
  }

  void _onSubmitted(String value) {
    final tagName = value.trim();
    if (tagName.isNotEmpty) {
      widget.onTagAdded?.call(tagName);
      _controller.clear();
      context.read<TagSuggestionBloc>().add(ClearTagSuggestions());
    }
    widget.onSubmitted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.tag),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      context.read<TagSuggestionBloc>().add(ClearTagSuggestions());
                    },
                  )
                : null,
          ),
          textInputAction: TextInputAction.done,
          onChanged: _onTextChanged,
          onSubmitted: _onSubmitted,
        ),
      ),
    );
  }
}
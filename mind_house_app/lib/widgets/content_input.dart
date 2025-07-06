import 'package:flutter/material.dart';

class ContentInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final EdgeInsetsGeometry? padding;
  final bool readOnly;

  const ContentInput({
    super.key,
    this.controller,
    this.hintText = 'Enter your information here...',
    this.labelText,
    this.maxLines,
    this.minLines = 3,
    this.expands = false,
    this.onChanged,
    this.onSubmitted,
    this.padding,
    this.readOnly = false,
  });

  @override
  State<ContentInput> createState() => _ContentInputState();
}

class _ContentInputState extends State<ContentInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText != null) ...[
            Text(
              widget.labelText!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          widget.expands
            ? Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: widget.readOnly,
                  maxLines: null,
                  minLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: const OutlineInputBorder(),
                    filled: widget.readOnly,
                    fillColor: widget.readOnly 
                      ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5)
                      : null,
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: !widget.readOnly && _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              widget.onChanged?.call('');
                            },
                          )
                        : null,
                  ),
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                ),
              )
            : TextField(
                controller: _controller,
                focusNode: _focusNode,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: const OutlineInputBorder(),
                  filled: widget.readOnly,
                  fillColor: widget.readOnly 
                    ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5)
                    : null,
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: !widget.readOnly && _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            widget.onChanged?.call('');
                          },
                        )
                      : null,
                ),
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => widget.onSubmitted?.call(),
              ),
          if (!widget.readOnly && _controller.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_controller.text.length} characters',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class SearchButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isActive;
  final bool isLoading;

  const SearchButton({
    super.key,
    this.onPressed,
    this.tooltip = 'Search',
    this.isActive = false,
    this.isLoading = false,
  });

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      tooltip: widget.tooltip,
      icon: widget.isLoading
          ? AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2.0 * 3.14159,
                  child: const Icon(Icons.refresh),
                );
              },
            )
          : Icon(
              widget.isActive ? Icons.search : Icons.search_outlined,
              color: widget.isActive
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
    );
  }
}

class SearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onClearPressed;
  final bool isLoading;
  final bool autofocus;

  const SearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onSearchPressed,
    this.onClearPressed,
    this.isLoading = false,
    this.autofocus = false,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClearPressed?.call();
    _focusNode.requestFocus();
  }

  void _handleSubmitted(String value) {
    widget.onSubmitted?.call(value);
    widget.onSearchPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: widget.isLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _handleClear,
                    tooltip: 'Clear',
                  ),
                  SearchButton(
                    onPressed: widget.onSearchPressed,
                    isActive: _controller.text.isNotEmpty,
                    isLoading: widget.isLoading,
                  ),
                ],
              )
            : null,
        border: const OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: _handleSubmitted,
    );
  }
}
import 'package:flutter/material.dart';

enum SaveButtonState {
  idle,
  loading,
  success,
  error,
}

class SaveButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final SaveButtonState state;
  final String idleText;
  final String loadingText;
  final String successText;
  final String errorText;
  final Duration animationDuration;
  final bool fullWidth;

  const SaveButton({
    super.key,
    this.onPressed,
    this.state = SaveButtonState.idle,
    this.idleText = 'Save',
    this.loadingText = 'Saving...',
    this.successText = 'Saved!',
    this.errorText = 'Error',
    this.animationDuration = const Duration(milliseconds: 300),
    this.fullWidth = false,
  });

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SaveButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      switch (widget.state) {
        case SaveButtonState.loading:
          _animationController.repeat(reverse: true);
          break;
        case SaveButtonState.success:
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          break;
        case SaveButtonState.error:
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          break;
        case SaveButtonState.idle:
          _animationController.reset();
          break;
      }
    }
  }

  Color _getButtonColor(BuildContext context) {
    switch (widget.state) {
      case SaveButtonState.idle:
      case SaveButtonState.loading:
        return Theme.of(context).colorScheme.primary;
      case SaveButtonState.success:
        return Colors.green;
      case SaveButtonState.error:
        return Theme.of(context).colorScheme.error;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (widget.state) {
      case SaveButtonState.idle:
      case SaveButtonState.loading:
        return Theme.of(context).colorScheme.onPrimary;
      case SaveButtonState.success:
        return Colors.white;
      case SaveButtonState.error:
        return Theme.of(context).colorScheme.onError;
    }
  }

  String _getButtonText() {
    switch (widget.state) {
      case SaveButtonState.idle:
        return widget.idleText;
      case SaveButtonState.loading:
        return widget.loadingText;
      case SaveButtonState.success:
        return widget.successText;
      case SaveButtonState.error:
        return widget.errorText;
    }
  }

  Widget _getIcon() {
    switch (widget.state) {
      case SaveButtonState.idle:
        return const Icon(Icons.save_outlined, size: 20);
      case SaveButtonState.loading:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(context)),
          ),
        );
      case SaveButtonState.success:
        return const Icon(Icons.check_circle_outline, size: 20);
      case SaveButtonState.error:
        return const Icon(Icons.error_outline, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedContainer(
            duration: widget.animationDuration,
            child: ElevatedButton.icon(
              onPressed: widget.state == SaveButtonState.loading 
                ? null 
                : widget.onPressed,
              icon: _getIcon(),
              label: Text(_getButtonText()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColor(context),
                foregroundColor: _getTextColor(context),
                disabledBackgroundColor: _getButtonColor(context).withOpacity(0.6),
                disabledForegroundColor: _getTextColor(context).withOpacity(0.6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
        );
      },
    );

    return widget.fullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }
}
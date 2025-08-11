import 'package:flutter/material.dart';

class NeonHoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  const NeonHoverButton({super.key, required this.child, this.onPressed});
  @override
  State<NeonHoverButton> createState() => _NeonHoverButtonState();
}

class _NeonHoverButtonState extends State<NeonHoverButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).elevatedButtonTheme.style!;
    final glow = Theme.of(context).colorScheme.secondary.withOpacity(0.22);

    return FocusableActionDetector(
      onShowFocusHighlight: (f) => setState(() => _hover = f),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: _hover || _pressed ? [BoxShadow(color: glow, blurRadius: 16, offset: const Offset(0, 6))] : const [],
            ),
            child: ElevatedButton(onPressed: widget.onPressed, style: style, child: widget.child),
          ),
        ),
      ),
    );
  }
}

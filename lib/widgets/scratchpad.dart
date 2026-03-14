import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Scratchpad extends StatefulWidget {
  final Function(String) onSave;
  final VoidCallback onCancel;

  const Scratchpad({super.key, required this.onSave, required this.onCancel});

  @override
  State<Scratchpad> createState() => _ScratchpadState();
}

class _ScratchpadState extends State<Scratchpad> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Delay slightly to ensure window is fully visible before grabbing keyboard focus
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Ensures the window frame is invisible
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onCancel();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.black12,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Icon(
                  Icons.flash_on_rounded,
                  color: Colors.deepPurpleAccent,
                  size: 28,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(fontSize: 20, fontFamily: 'Courier'),
                  decoration: InputDecoration(
                    hintText: "Jot down a quick note...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white30 : Colors.black38,
                      fontFamily: 'Courier',
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      widget.onSave(val.trim());
                    } else {
                      widget.onCancel();
                    }
                    _controller.clear();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "⏎ to Save  |  ESC to Cancel",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white30 : Colors.black38,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

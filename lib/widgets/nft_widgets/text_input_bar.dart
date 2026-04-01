import 'package:flutter/material.dart';

const kOrange = Color(0xFFF5A623);

class TextInputBar extends StatefulWidget {
  final Function(String text, Color color, double size) onSubmit;
  final VoidCallback onCancel;
  final Color initialColor;

  const TextInputBar({
    super.key,
    required this.onSubmit,
    required this.onCancel,
    required this.initialColor,
  });

  @override
  State<TextInputBar> createState() => _TextInputBarState();
}

class _TextInputBarState extends State<TextInputBar> {
  final _ctrl = TextEditingController();
  late Color _color;
  double _size = 24;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  style: TextStyle(color: _color, fontSize: _size),
                  decoration: const InputDecoration(
                    hintText: 'Type your text...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_ctrl.text.isNotEmpty) {
                    widget.onSubmit(_ctrl.text, _color, _size);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Size:',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: kOrange,
                    thumbColor: kOrange,
                    inactiveTrackColor: Colors.grey,
                  ),
                  child: Slider(
                    value: _size,
                    min: 10,
                    max: 60,
                    onChanged: (v) => setState(() => _size = v),
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onCancel,
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

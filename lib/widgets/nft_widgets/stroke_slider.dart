import 'package:flutter/material.dart';

const kOrange = Color(0xFFF5A623);

class StrokeSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onClose;

  const StrokeSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onClose,
  });

  @override
  State<StrokeSlider> createState() => _StrokeSliderState();
}

class _StrokeSliderState extends State<StrokeSlider> {
  late double _val;

  @override
  void initState() {
    super.initState();
    _val = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Width',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: kOrange,
                thumbColor: kOrange,
                inactiveTrackColor: Colors.grey,
              ),
              child: Slider(
                value: _val,
                min: 1,
                max: 30,
                onChanged: (v) {
                  setState(() => _val = v);
                  widget.onChanged(v);
                },
              ),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: _val.clamp(2, 24),
                height: _val.clamp(2, 24),
                decoration: const BoxDecoration(
                  color: kOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onClose,
            child: const Icon(Icons.close, color: Colors.grey, size: 16),
          ),
        ],
      ),
    );
  }
}

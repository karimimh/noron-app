import 'package:flutter/material.dart';

class ExpandableContainer extends StatefulWidget {
  const ExpandableContainer({super.key});

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  double _containerHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _containerHeight += details.delta.dy;
        });
      },
      child: Container(
        height: _containerHeight,
        color: Colors.blue,
        child: const Center(
          child: Text(
            'Drag to expand',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}

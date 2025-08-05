import 'package:flutter/material.dart';

/// Reusable mentor avatar widget
/// Displays circular avatar with mentor name
class MentorAvatar extends StatelessWidget {
  final String name;
  final double size;
  final VoidCallback? onTap;

  const MentorAvatar({
    super.key,
    required this.name,
    this.size = 0.08,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: width * size,
            backgroundColor: Colors.black,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}

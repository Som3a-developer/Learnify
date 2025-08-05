import 'package:flutter/material.dart';
import 'package:learnify/const.dart';
import 'package:learnify/widgets/texts.dart';

/// Reusable course card widget
/// Displays course image, title, category and price
class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.45,
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(width * 0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height * 0.1,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
              child: course['url'] != null
                  ? Image.network(course['url'], fit: BoxFit.cover)
                  : null,
            ),
            SizedBox(height: height * 0.015),
            Text(
              course['category']?.toString() ?? '-',
              style: TextStyle(fontSize: 12, color: Colors.orange),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: height * 0.005),
            Text(
              course['title']?.toString() ?? '-',
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: height * 0.005),
            Text(
              '\$${course['price']}   |   ${course['students'] ?? '-'} Std',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

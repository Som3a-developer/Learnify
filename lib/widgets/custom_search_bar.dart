import 'package:learnify/const.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    this.width, // أصبح اختياريًا الآن
    this.onChanged,
    this.controller,
    this.onSubmitted,
    this.onClear,
    this.hintText = 'Search for..',
    this.borderRadius = 12.0,
  });

  final double? width; // أصبح nullable
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final void Function(String)? onSubmitted;
  final void Function()? onClear;
  final String hintText;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    // استخدام عرض الشاشة إذا لم يتم تحديد width
    final effectiveWidth = width ?? MediaQuery.of(context).size.width;
    final effectiveBorderRadius =
        borderRadius * (effectiveWidth / 375.0); // تكيف مع أحجام الشاشات

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          fillColor: Colors.white,
          filled: true,
          suffixIcon: _buildSuffixIcon(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: effectiveWidth * 0.04,
            vertical: effectiveWidth * 0.035,
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    // إذا كان هناك controller ونص، نعرض زر المسح
    if (controller != null && (controller?.text.isNotEmpty ?? false)) {
      return IconButton(
        icon: Icon(Icons.clear, color: blueColor()),
        onPressed: () {
          controller?.clear();
          onClear?.call();
        },
      );
    }
    // وإلا نعرض أيقونة البحث العادية
    return Icon(Icons.manage_search, color: blueColor());
  }
}

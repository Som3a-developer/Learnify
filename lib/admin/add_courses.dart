import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:learnify/const.dart';
import 'package:learnify/extentions.dart';
import 'package:learnify/widgets/custom_textfield.dart';
import 'package:learnify/widgets/texts.dart';
import 'package:learnify/Helpers/dio_helper.dart';
import 'package:learnify/Helpers/hive_helper.dart';

class AddCoursesScreen extends StatelessWidget {
  const AddCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = context.height;
    final w = context.width;

    final _formKey = GlobalKey<FormState>();
    final categoryController = TextEditingController();
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final urlController = TextEditingController();

    clear() {
      categoryController.clear();
      titleController.clear();
      priceController.clear();
      urlController.clear();
    }

    Future<void> addCourse() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      try {
        final res = await DioHelper.postData(
          path: "courses",
          body: {
            "category": categoryController.text.trim(),
            "title": titleController.text.trim(),
            "points": int.parse(priceController.text.trim()),
            "url": urlController.text.trim(),
            "publisher": HiveHelper.getUserName(),
          },
        );
        print("RESPONSE: $res");
        clear();
        Get.snackbar("Success", "Course Added Successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        Get.snackbar("Error", "Failed to add course: $e",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: boldtexts("Add Courses"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding(w)),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: h * .02,
              children: [
                boldtexts("Enter Category"),
                CustomTextfield(
                  text: "Category",
                  controller: categoryController,
                  prefixIcon: Icon(Icons.category),
                  validator: (value) => value == null || value.isEmpty
                      ? "Category required"
                      : null,
                ),
                boldtexts("Enter Title"),
                CustomTextfield(
                  text: "Title",
                  controller: titleController,
                  prefixIcon: Icon(Icons.title),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Title required" : null,
                ),
                boldtexts("Enter price"),
                CustomTextfield(
                  text: "Price",
                  controller: priceController,
                  prefixIcon: Icon(Icons.money),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Price required";
                    }
                    if (int.tryParse(value) == null) {
                      return "Enter a valid number";
                    }
                    return null;
                  },
                ),
                boldtexts("Enter URL"),
                CustomTextfield(
                  text: "URL",
                  controller: urlController,
                  prefixIcon: Icon(Icons.link_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "URL required";
                    }
                    final regex = RegExp(
                        r'^(http|https):\/\/([\w\-]+\.)+[\w\-]+(\/[\w\-./?%&=]*)?$');
                    if (!regex.hasMatch(value.trim())) {
                      return "Enter a valid URL";
                    }
                    return null;
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    await addCourse();
                  },
                  child: signButton(h: h, text: "Add Course"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

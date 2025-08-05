import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:learnify/const.dart';
import 'package:learnify/extentions.dart';
import 'package:learnify/firebase/firestore.dart';
import 'package:learnify/widgets/custom_textfield.dart';
import 'package:learnify/widgets/texts.dart';

class AddCoursesScreen extends StatelessWidget {
  const AddCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = context.height;
    final w = context.width;
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

    return Scaffold(
      appBar: AppBar(
        title: boldtexts("Add Courses"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding(w)),
          child: Column(
            spacing: h * .02,
            children: [
              boldtexts("Enter Category"),
              CustomTextfield(
                text: "Category",
                controller: categoryController,
                prefixIcon: Icon(Icons.category),
              ),
              boldtexts("Enter Title"),
              CustomTextfield(
                text: "Title",
                controller: titleController,
                prefixIcon: Icon(Icons.title),
              ),
              boldtexts("Enter price"),
              CustomTextfield(
                text: "price",
                controller: priceController,
                prefixIcon: Icon(Icons.money),
              ),
              boldtexts("Enter URL"),
              CustomTextfield(
                text: "URL",
                controller: urlController,
                prefixIcon: Icon(Icons.link_outlined),
              ),
              GestureDetector(
                onTap: () {
                  Firestore().addCategory(
                    category: categoryController.text,
                    price: priceController.text,
                    title: titleController.text,
                    url: urlController.text,
                  );
                  clear();
                  Get.snackbar("Success", "Course Added Successfully");
                },
                child: signButton(h: h, text: "Add Course"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

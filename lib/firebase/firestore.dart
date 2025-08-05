import 'package:learnify/Helpers/hive_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  int i = 2;
  CollectionReference courses =
      FirebaseFirestore.instance.collection("Courses");
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addCategory({
    required String category,
    required String title,
    required String price,
    required String url,
  }) async {
    await courses.add(
      {
        "id": FieldValue.increment(1),
        "category": category,
        "title": title,
        "price": price,
        "url": url,
        "publisher": HiveHelper.getUserName(),
      },
    );
    i++;
  }

  getData() async {
    List<QueryDocumentSnapshot> data = [];
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Courses").get();
    data.addAll(querySnapshot.docs);

    return data;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final Map categories;

  CategoryModel(this.categories);

  factory CategoryModel.fromDocument(DocumentSnapshot doc) {
    return CategoryModel(doc['categories']);
  }
}

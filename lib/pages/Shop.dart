import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nova_fashion_admin/main.dart';
import 'package:nova_fashion_admin/models/CategoryModel.dart';
import 'package:nova_fashion_admin/widget/widgets.dart';

import 'NewCategory.dart';
import 'NewProduct.dart';

class Shop extends StatefulWidget {
  @override
  _ShopState createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  TextEditingController _collectionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Divider(height: 0, color: Colors.black26),
            Container(
              color: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Colors.redAccent.withOpacity(0.2),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add new Product'),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewProduct()));
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(
                            color: Color(0xFFFF7576),
                            borderRadius: BorderRadius.all(Radius.circular(4))),
                        child:
                            Text('ADD', style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Divider(height: 0, color: Colors.black26),
            SizedBox(height: 20),
            Divider(height: 0, color: Colors.black26),
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: 50,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add new collection'),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('New Collection'),
                            content: TextField(
                              controller: _collectionController,
                              decoration: InputDecoration(
                                labelText: 'Collection name',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await collectionRef.doc('collections').set({
                                    'collections': {
                                      _collectionController.text: {}
                                    }
                                  });
                                  await categoryRef
                                      .doc(_collectionController.text)
                                      .set({'categories': {}});
                                  Navigator.pop(context);
                                },
                                child: Text('ADD'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                          color: Color(0xFFFF7576),
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: Text('ADD', style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
            Divider(height: 0, color: Colors.black26),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
                stream: categoryRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(height: 15),
                    shrinkWrap: true,
                    itemCount: snapshot.data.size,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      CategoryModel categoryModel =
                          CategoryModel.fromDocument(snapshot.data.docs[index]);
                      List categories = [];
                      categoryModel.categories.forEach((key, value) {
                        categories.add(value);
                      });
                      return Column(
                        children: [
                          Divider(height: 0, color: Colors.black26),
                          Container(
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(snapshot.data.docs[index].id,
                                    style: TextStyle(fontSize: 18)),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => NewCategory(
                                                documentRef: categoryRef.doc(
                                                    snapshot
                                                        .data.docs[index].id),
                                                collectionName: snapshot
                                                    .data.docs[index].id)));
                                  },
                                  child: Text('Add category',
                                      style:
                                          TextStyle(color: Color(0xFFFF7576))),
                                )
                              ],
                            ),
                          ),
                          categories.length == 0
                              ? Container()
                              : Container(
                                  color: Colors.white,
                                  child: GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: categories.length,
                                    padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 10,
                                        top: 10),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                            childAspectRatio: 0.75),
                                    itemBuilder: (context, gIndex) {
                                      return categoryWidget(
                                          categories,
                                          gIndex,
                                          context,
                                          snapshot.data.docs[index].id);
                                    },
                                  ),
                                ),
                          Divider(height: 0, color: Colors.black26),
                        ],
                      );
                    },
                  );
                })
          ],
        ),
      ),
    );
  }
}

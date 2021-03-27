import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:nova_fashion_admin/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewCategory extends StatefulWidget {
  final DocumentReference documentRef;
  final String collectionName;
  final bool subCategory;
  final String subCollectionName;
  final String subCategoryName;

  const NewCategory(
      {Key key,
      this.documentRef,
      this.collectionName,
      this.subCategory = false,
      this.subCollectionName,
      this.subCategoryName})
      : super(key: key);

  @override
  _NewCategoryState createState() => _NewCategoryState();
}

class _NewCategoryState extends State<NewCategory> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File file;
  TextEditingController _categoryNameController = TextEditingController();
  bool isUploading = false;
  String fileException = '';
  String uuid = Uuid().v4();

  handleTakePhoto() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Photo with Camera"),
                ),
                onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Image from Gallery"),
                ),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Cancel"),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage(userId) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$userId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 30));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile, userId) async {
    UploadTask uploadTask =
        storageRef.child("category_$uuid.jpg").putFile(imageFile);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({String mediaUrl, String categoryName}) async {
    DocumentSnapshot categories = await widget.documentRef.get();
    Map categoriesValue = categories.data()['categories'];
    categoriesValue[categoryName] = {
      'mediaUrl': mediaUrl,
      'categoryName': categoryName
    };
    DocumentSnapshot collections = await collectionRef.doc('collections').get();
    Map collectionsValue = collections.data()['collections'];
    if (widget.subCategory) {
      collectionsValue[widget.subCollectionName][widget.subCategoryName]
              [widget.collectionName]
          .add(categoryName);
    } else {
      collectionsValue[widget.collectionName][categoryName] = {};
    }
    await collectionRef
        .doc('collections')
        .set({'collections': collectionsValue});
    await widget.documentRef.set({'categories': categoriesValue});
  }

  handleSubmit(String userId) async {
    setState(() {
      isUploading = true;
    });
    if (file != null) {
      await compressImage(userId);
    }
    String mediaUrl = file == null ? '' : await uploadImage(file, userId);
    createPostInFirestore(
        mediaUrl: mediaUrl, categoryName: _categoryNameController.text);
    _categoryNameController.clear();
    setState(() {
      file = null;
      uuid = Uuid().v4();
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User _firebaseUser = context.watch<User>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('New Category', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 15),
                Text('Select Category Image',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                SizedBox(height: 10),
                file == null
                    ? Center(
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth: 150,
                              maxWidth: 250,
                              minHeight: 150,
                              maxHeight: 250),
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Center(
                            child: InkWell(
                              onTap: () => selectImage(context),
                              child: Container(
                                height: 45,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: Color(0xFFFF7576),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                child: Center(
                                  child: Text('Upload image',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          Center(
                            child: Container(
                              constraints: BoxConstraints(
                                  minWidth: 150,
                                  maxWidth: 250,
                                  minHeight: 150,
                                  maxHeight: 250),
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  image: DecorationImage(
                                      image: FileImage(file),
                                      fit: BoxFit.cover)),
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            right: 100,
                            child: InkWell(
                              onTap: () => clearImage(),
                              child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.delete, color: Colors.red)),
                            ),
                          )
                        ],
                      ),
                fileException == '' ? Container() : SizedBox(height: 4),
                fileException == ''
                    ? Container()
                    : Text('Please select any image',
                        style: TextStyle(color: Colors.red)),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value.length == 0) {
                        return 'Please enter category name';
                      }
                      return null;
                    },
                    controller: _categoryNameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        labelText: 'Enter category name',
                        border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: (!isUploading)
                      ? () async {
                          if (file == null) {
                            setState(() {
                              fileException = 'Please select any image';
                            });
                            return;
                          }
                          fileException = '';
                          if (_formKey.currentState.validate()) {
                            await handleSubmit(_firebaseUser.uid);
                            Navigator.pop(context);
                          }
                        }
                      : null,
                  child: Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: isUploading
                          ? Color(0xFFFF7576).withOpacity(0.5)
                          : Color(0xFFFF7576),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Center(
                        child: Text(
                      isUploading ? 'Adding...' : 'Add',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

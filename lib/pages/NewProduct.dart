import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:nova_fashion_admin/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class NewProduct extends StatefulWidget {
  @override
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File file;
  TextEditingController _productNameController = TextEditingController();
  TextEditingController tc = TextEditingController();
  TextEditingController _sizeController = TextEditingController();
  int currentTextLength = 0;
  bool isUploading = false;
  String fileException = '';
  String uuid = Uuid().v4();
  List sizes = [];
  List colors = [];
  List images = [];
  bool sizeSwitch = false;

  List colorsList = [];

  Color screenPickerColor;
  Color dialogPickerColor;

  @override
  void initState() {
    super.initState();
    screenPickerColor = Colors.blue;
    dialogPickerColor = Colors.red;
  }

  // Define custom colors. The 'guide' color values are from
  // https://material.io/design/color/the-color-system.html#color-theme-creation
  static const Color guidePrimary = Color(0xFF6200EE);
  static const Color guidePrimaryVariant = Color(0xFF3700B3);
  static const Color guideSecondary = Color(0xFF03DAC6);
  static const Color guideSecondaryVariant = Color(0xFF018786);
  static const Color guideError = Color(0xFFB00020);
  static const Color guideErrorDark = Color(0xFFCF6679);
  static const Color blueBlues = Color(0xFF174378);

  // Make a custom ColorSwatch to name map from the above custom colors.
  final Map<ColorSwatch<Object>, String> colorsNameMap =
      <ColorSwatch<Object>, String>{
    ColorTools.createPrimarySwatch(guidePrimary): 'Guide Purple',
    ColorTools.createPrimarySwatch(guidePrimaryVariant): 'Guide Purple Variant',
    ColorTools.createAccentSwatch(guideSecondary): 'Guide Teal',
    ColorTools.createAccentSwatch(guideSecondaryVariant): 'Guide Teal Variant',
    ColorTools.createPrimarySwatch(guideError): 'Guide Error',
    ColorTools.createPrimarySwatch(guideErrorDark): 'Guide Error Dark',
    ColorTools.createPrimarySwatch(blueBlues): 'Blue blues',
  };

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

  handleChooseFromGallery({multipleImages = false}) async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (multipleImages) {
        this.file = file;
      } else {
        images.add(file);
      }
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
    // DocumentSnapshot categories = await widget.documentRef.get();
    // Map categoriesValue = categories.data()['categories'];
    // categoriesValue[categoryName] = {
    //   'mediaUrl': mediaUrl,
    //   'categoryName': categoryName
    // };
    // widget.documentRef.set({'categories': categoriesValue});
  }

  handleSubmit(String userId) async {
    setState(() {
      isUploading = true;
    });
    if (file != null) {
      await compressImage(userId);
    }
    // String mediaUrl = file == null ? '' : await uploadImage(file, userId);
    // createPostInFirestore(
    //     mediaUrl: mediaUrl, categoryName: _categoryNameController.text);
    // _categoryNameController.clear();
    // setState(() {
    //   file = null;
    //   uuid = Uuid().v4();
    //   isUploading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('New Product', style: TextStyle(color: Colors.black)),
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
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Text('Upload Product Image',
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
                                    child:
                                        Icon(Icons.delete, color: Colors.red)),
                              ),
                            )
                          ],
                        ),
                  SizedBox(height: 20),
                  Divider(height: 0, color: Colors.black26),
                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Photos', style: TextStyle(fontSize: 16)),
                        InkWell(
                          onTap: () {
                            selectImage(context);
                          },
                          child: Center(
                              child: Text('Add',
                                  style: TextStyle(
                                      color: Color(0xFFFF7576), fontSize: 16))),
                        )
                      ]),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(images[index]))),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 10),
                        itemCount: images.length),
                  ),
                  SizedBox(height: 20),
                  Divider(height: 0, color: Colors.black26),
                  SizedBox(height: 50),
                  TextFormField(
                    validator: (value) {
                      if (value.length == 0) {
                        return 'Product name cannot be null';
                      }
                      return null;
                    },
                    controller: _productNameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.redAccent.withOpacity(0.1),
                        labelText: 'Product name',
                        isDense: true,
                        border:
                            OutlineInputBorder(borderSide: BorderSide.none)),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                      minLines: 5,
                      maxLines: null,
                      controller: tc,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.redAccent.withOpacity(0.1),
                        labelText: 'Product description',
                        isDense: true,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      onChanged: (String newText) {
                        if (newText[0] != '•') {
                          newText = '• ' + newText;
                          tc.text = newText;
                          tc.selection = TextSelection.fromPosition(
                              TextPosition(offset: tc.text.length));
                        }
                        if (newText[newText.length - 1] == '\n' &&
                            newText.length > currentTextLength) {
                          tc.text = newText + '• ';
                          tc.selection = TextSelection.fromPosition(
                              TextPosition(offset: tc.text.length));
                        }
                        currentTextLength = tc.text.length;
                      }),
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.redAccent.withOpacity(0.1),
                      labelText: 'MRP (in Rupees)',
                      isDense: true,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.redAccent.withOpacity(0.1),
                      labelText: 'Price (in Rupees)',
                      isDense: true,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.redAccent.withOpacity(0.1),
                      labelText: 'Stock',
                      isDense: true,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Size', style: TextStyle(fontSize: 16)),
                      Switch(
                        value: sizeSwitch,
                        onChanged: (value) {
                          setState(() {
                            sizeSwitch = value;
                          });
                        },
                        activeTrackColor: Color(0xFFFF7576).withOpacity(0.2),
                        activeColor: Color(0xFFFF7576),
                      ),
                    ],
                  ),
                  sizeSwitch ? SizedBox(height: 5) : Container(),
                  sizeSwitch
                      ? Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _sizeController,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.redAccent.withOpacity(0.1),
                                  labelText: 'Add Sizes',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  sizes.add(_sizeController.text);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF7576),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                height: 50,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Center(
                                  child: Text('Add',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  sizeSwitch ? SizedBox(height: 10) : Container(),
                  sizeSwitch
                      ? Wrap(
                          runSpacing: 10,
                          spacing: 10,
                          children: sizes
                              .map((size) => Chip(
                                    labelPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    label: Text(size,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                    backgroundColor: Color(0xFFFF7576),
                                    deleteIcon: Icon(Icons.clear),
                                    onDeleted: () {
                                      setState(() {
                                        sizes.remove(size);
                                      });
                                    },
                                    deleteIconColor: Colors.white,
                                  ))
                              .toList()
                              .cast<Widget>(),
                        )
                      : Container(),
                  SizedBox(height: 20),
                  ListTile(
                    title: const Text('Click this color to change'),
                    subtitle: Text(
                      '${ColorTools.nameThatColor(dialogPickerColor)}',
                    ),
                    trailing: ColorIndicator(
                      width: 44,
                      height: 44,
                      borderRadius: 4,
                      color: dialogPickerColor,
                      onSelect: () async {
                        final Color colorBeforeDialog = dialogPickerColor;
                        if (!(await colorPickerDialog())) {
                          setState(() {
                            dialogPickerColor = colorBeforeDialog;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      setState(() {
                        colorsList.add({
                          'name': ColorTools.nameThatColor(dialogPickerColor),
                          'code': ColorTools.colorCode(dialogPickerColor)
                        });
                        colors.add(ColorTools.materialName(dialogPickerColor,
                            withIndex: false));
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFF7576),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child:
                            Text('Add', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: colorsList
                        .map((color) => Chip(
                              labelPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              label: Text(color['name'],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
                              backgroundColor: Color(0xFFFF7576),
                              avatar: CircleAvatar(
                                backgroundColor:
                                    Color(int.parse('0x${color['code']}')),
                              ),
                              deleteIcon: Icon(Icons.clear),
                              onDeleted: () {
                                setState(() {
                                  colorsList.remove(color);
                                });
                              },
                              deleteIconColor: Colors.white,
                            ))
                        .toList()
                        .cast<Widget>(),
                  ),
                  SizedBox(height: 100)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      color: dialogPickerColor,
      onColorChanged: (Color color) =>
          setState(() => dialogPickerColor = color),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 200,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      showMaterialName: false,
      showColorName: true,
      showColorCode: false,
      materialNameTextStyle: Theme.of(context).textTheme.caption,
      colorNameTextStyle: Theme.of(context).textTheme.caption,
      colorCodeTextStyle: Theme.of(context).textTheme.caption,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
      customColorSwatchesAndNames: colorsNameMap,
    ).showPickerDialog(
      context,
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }
}

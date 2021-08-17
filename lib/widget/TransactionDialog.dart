import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/transaction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class TransactionDialog extends StatefulWidget {
  final Transaction? transaction;
  final Function(String name, String director, String path) onClickedDone;
  const TransactionDialog({
    Key? key,
    this.transaction,
    required this.onClickedDone,
  }) : super(key: key);
  @override
  _TransactionDialogState createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final directorController = TextEditingController();
  //final pathController = TextEditingController();
  bool ni = true;
  final Image tempim = Image.asset("assets/img.png");
  late XFile _image;
  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    ni = false;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      nameController.text = transaction.name;
      directorController.text = transaction.director;
      //  pathController.text = transaction.path;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    directorController.dispose();
    // pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    // ni = isEditing ? false : true;
    final title = isEditing ? 'Edit Movie' : 'Add Movie';
    return Container(
      color: Colors.black54,
      child: AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.redAccent,
              color: Colors.white),
        ),
        content: Container(
          // color: Colors.black54,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 8,
                  ),
                  buildName(),
                  SizedBox(
                    height: 8,
                  ),
                  buildDirector(),
                  SizedBox(
                    height: 8,
                  ),
                  buildPath(),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          buildCancelButton(context),
          buildAddButton(context, isEditing: isEditing),
        ],
      ),
    );
  }

  Widget buildName() => TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter Movie Name',
        ),
        validator: (name) =>
            name != null && name.isEmpty ? 'Enter a name' : null,
      );
  Widget buildDirector() => TextFormField(
        controller: directorController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter Director Name',
        ),
        validator: (director) =>
            director != null && director.isEmpty ? 'Enter a name' : null,
      );
  Widget buildPath() => (Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.redAccent,
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            onPressed: pickImage,
            child: Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                'Add Poster',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          ni
              ? Container(
                  width: 150,
                  height: 150,
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  child: tempim,
                )
              : Container(
                  width: 150,
                  height: 150,
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  child: Image.file(
                    File(_image.path),
                    fit: BoxFit.contain,
                  ),
                ),

          // Image.file(File(_image.path)),
          SizedBox(
            height: 20,
          ),
        ],
      ));
  Widget buildCancelButton(BuildContext context) => TextButton(
        child: Text(
          'Cancel',
          style: TextStyle(color: Colors.redAccent),
        ),
        onPressed: () => Navigator.of(context).pop(),
      );

  Widget buildAddButton(BuildContext context, {required bool isEditing}) {
    final text = isEditing ? 'Save' : 'Add';

    return TextButton(
      child: Text(text),
      onPressed: () async {
        final isValid = formKey.currentState!.validate();

        if (isValid) {
          final name = nameController.text;
          final director = directorController.text;
          final path = _image.path;

          widget.onClickedDone(name, director, path);

          Navigator.of(context).pop();
        }
      },
    );
  }
}

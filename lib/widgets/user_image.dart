import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImage extends StatefulWidget {
  const UserImage({super.key, required this.onPickImage});

  final void Function (File pickedImage)onPickImage;
  @override
  State<UserImage> createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  File? _pickedImageFile;

  void _pickedImage()async{
   final XFile? pickedImage = await ImagePicker().pickImage(
        source: ImageSource.camera,
      maxWidth: 150,
      imageQuality: 50,
    );
   if(pickedImage==null){
     return;
   }
   setState(() {
     _pickedImageFile=File(pickedImage.path);

   });
   widget.onPickImage(_pickedImageFile!);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedImageFile==null?null:FileImage(_pickedImageFile!),
        ),
        TextButton.icon(
            onPressed: _pickedImage,
            icon: Icon(Icons.image),
            label: Text(
              'Add Image',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
        )
      ],
    );
  }
}

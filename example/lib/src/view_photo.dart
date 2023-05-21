import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ViewPhoto extends StatelessWidget {
  const ViewPhoto({
    required this.image,
    super.key,
  });

  final XFile image;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.file(File(image.path)),
    );
  }
}

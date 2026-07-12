import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:two_one_two_messenger/utils/theme.dart';
import 'package:two_one_two_messenger/utils/utils.dart';

class ImageEditorScreen extends StatelessWidget {
  final File selectedFile;
  final Function(File) onImageEdited;

  const ImageEditorScreen({
    super.key,
    required this.selectedFile,
    required this.onImageEdited,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Edit Image")),
      body: ProImageEditor.file(
        selectedFile,
        configs: ProImageEditorConfigs(theme: AppTheme.darkTheme),
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (editedImage) async {
            File file = await Utils.uint8ListToFile(editedImage,
                DateTime.now().millisecondsSinceEpoch.toString());
            Navigator.pop(context);
            // Pass edited image back
            onImageEdited(file);

            // Close the editor screen
          },
          // onCloseEditor: () {
          //   debugPrint("close Editor");
          //   // Navigator.pop(context);
          // },
        ),
      ),
    );
  }
}

# app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

# Flutter File Download Example

This Flutter application demonstrates how to download a file from a given URL and save it to the device's storage. The app also includes functionalities to handle permissions, display download progress, and open the downloaded file.

## Features

- Downloads a file from a given URL.
- Saves the file to the device's external storage (Android) or application documents directory (iOS).
- Handles storage permissions for Android.
- Displays download progress in the console.
- Notifies the user when the download is complete and provides an option to open the file.

## Dependencies

This project uses the following packages:

- `flutter/material.dart`: For building the UI.
- `dio`: For handling HTTP requests and file downloads.
- `path_provider`: For accessing the device's storage paths.
- `permission_handler`: For handling permissions on Android.
- `open_file`: For opening the downloaded file.
- `dart:io`: For platform-specific code.

## Getting Started

1. **Add dependencies**:
   
   Add the following dependencies to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     dio: ^4.0.0
     path_provider: ^2.0.2
     permission_handler: ^8.1.4
     open_file: ^3.2.1

2.Import packages:
```dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: DownloadFilePage(),
  ));
}

class DownloadFilePage extends StatelessWidget {
  // final String fileUrl = "https://pdfobject.com/pdf/sample.pdf";

  final String fileUrl =
      "https://backend.avyaas.com/images/subjectLight/icons/mbbs/batch-(mo1).png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download File"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _downloadFile(context, fileUrl);
          },
          child: Text("Download File"),
        ),
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context, String url) async {
    final dio = Dio();
    final String fileName = url.split('/').last; // Extract file name from URL

    try {
      if (await _requestPermissions()) {
        String filePath;

        if (Platform.isAndroid) {
          final downloadsDir = await getExternalStorageDirectory();
          filePath = "${downloadsDir!.path}/$fileName";
        } else if (Platform.isIOS) {
          final dir = await getApplicationDocumentsDirectory();
          filePath = "${dir.path}/$fileName";
        } else {
          throw UnsupportedError('Unsupported platform');
        }

        await dio.download(url, filePath, onReceiveProgress: (received, total) {
          if (total != -1) {
            print((received / total * 100).toStringAsFixed(0) + "%");
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("File downloaded to $filePath"),
        ));

        _showDownloadDialog(context, filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Permission denied"),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error downloading file: $e"),
      ));
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    }
    return true;
  }

  void _showDownloadDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Download Complete"),
          content: Text("File downloaded to: $filePath"),
          actions: [
            TextButton(
              child: Text("Open"),
              onPressed: () {
                OpenFile.open(filePath);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
```

4. Run the app:

Use the following command to run the app on your device or emulator:

flutter run


5.Notes
Make sure to replace the fileUrl with the URL of the file you want to download.
Ensure you have proper permissions set up in your Android AndroidManifest.xml for storage access.
For iOS, ensure you have the necessary permissions configured in your Info.plist.
Conclusion
This example demonstrates a simple and effective way to handle file downloads in a Flutter application. By leveraging various packages, we can manage permissions, download files, and provide a seamless user experience.



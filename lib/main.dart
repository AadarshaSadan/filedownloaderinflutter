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

class DownloadFilePage extends StatefulWidget {
  @override
  _DownloadFilePageState createState() => _DownloadFilePageState();
}

class _DownloadFilePageState extends State<DownloadFilePage> {
  // final String fileUrl = "https://pdfobject.com/pdf/sample.pdf";
  final String fileUrl = "https://backend.avyaas.com/images/subjectLight/icons/mbbs/batch-(mo1).png";

  
  bool downloading = false;
  double downloadProgress = 0.0;
  String filePath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download File"),
      ),
      body: Center(
        child: downloading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(value: downloadProgress),
            SizedBox(height: 20.0),
            Text(
              '${(downloadProgress * 100).toStringAsFixed(2)} %',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        )
            : ElevatedButton(
          onPressed: () {
            _startDownload();
          },
          child: Text("Download File"),
        ),
      ),
    );
  }

  Future<void> _startDownload() async {
    setState(() {
      downloading = true;
      downloadProgress = 0.0;
    });

    final dio = Dio();
    final String fileName = fileUrl.split('/').last; // Extract file name from URL

    try {
      if (await _requestPermissions()) {
        if (Platform.isAndroid) {
          final downloadsDir = await getExternalStorageDirectory();
          filePath = "${downloadsDir!.path}/$fileName";
        } else if (Platform.isIOS) {
          final dir = await getApplicationDocumentsDirectory();
          filePath = "${dir.path}/$fileName";
        } else {
          throw UnsupportedError('Unsupported platform');
        }

        await dio.download(
          fileUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                downloadProgress = received / total;
              });
            }
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File downloaded to $filePath"),
          ),
        );

        _showDownloadDialog(context, filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Permission denied"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error downloading file: $e"),
        ),
      );
    } finally {
      setState(() {
        downloading = false;
      });
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

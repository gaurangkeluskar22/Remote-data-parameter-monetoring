import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Data.dart';

class TabularPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  TabularPage({Key key}) : super(key: key);

  @override
  TabularPageState createState() => TabularPageState();
}

class TabularPageState extends State<TabularPage> {
  List<Data> tempdata;
  List<Data> tabledata;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RDPM'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('Sensor-Data')
          .orderBy("timestamp")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          tempdata = snapshot.data.documents
              .map((documentSnapshot) => Data.fromMap(documentSnapshot.data))
              .toList();

          return _buildChart(context, tempdata);
        }
      },
    );
  }

  Widget _buildChart(BuildContext context, List<Data> tempdata) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Center(
                      child: Text("Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )))),
              Expanded(
                  child: Center(
                child: Text("Temperature",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
              )),
              Expanded(
                  child: Center(
                child: Text("Humidity",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
              )),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          _show_table_data(context),
          SizedBox(
            height: 10.0,
          ),
          RaisedButton(
            onPressed: () => create_and_download_sheet(),
            child: Text(
              "Download Excel sheet",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.blue,
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  Widget _show_table_data(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.3,
        child: ListView.builder(
            itemCount: tempdata.length,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Center(
                              child: Text('${tempdata[index].timestamp}'))),
                      Expanded(
                          child: Center(
                              child: Text('${tempdata[index].temp} °C'))),
                      Expanded(
                          child: Center(
                              child: Text('${tempdata[index].humidity} %'))),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Future<void> create_and_download_sheet() async {
    if (await _checkAndGetPermission() != null) {
      final Directory appdirectory = await getExternalStorageDirectory();
      final Directory directory =
          await Directory(appdirectory.path + '/files').create(recursive: true);
      final String dir = directory.path;
      final String url = "https://rtpra.herokuapp.com/download";

      try {
        print("in download");
        final taskId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: dir,
          showNotification:
              true, // show download progress in status bar (for Android)
          openFileFromNotification:
              true, // click on notification to open downloaded file (for Android)
        );
        setState(() {});
      } on PlatformException catch (e) {
        print(e);
      }
    }
  }

  static Future<bool> _checkAndGetPermission() async {
    final PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      final Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions(<PermissionGroup>[PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
        return null;
      }
    }
    return true;
  }
}

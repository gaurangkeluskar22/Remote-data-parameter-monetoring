import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/Shared/header.dart';

import '../Data.dart';

class GraphPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  GraphPage({Key key}) : super(key: key);

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
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
      appBar: header(context, titleText: "Graph"),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('Sensor-Data')
          .orderBy('timestamp')
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
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: SfCartesianChart(
              zoomPanBehavior: ZoomPanBehavior(enablePinching: true),
              trackballBehavior: TrackballBehavior(enable: true),
              primaryXAxis: CategoryAxis(),
              // Chart title
              title: ChartTitle(text: 'Humidity & Temperature graph'),
              // Enable legend
              legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<Data, String>>[
                LineSeries<Data, String>(
                    dataSource: tempdata,
                    xValueMapper: (Data data, _) => data.timestamp.toString(),
                    yValueMapper: (Data data, _) => data.humidity,
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: true)),
                LineSeries<Data, String>(
                    dataSource: tempdata,
                    xValueMapper: (Data data, _) => data.timestamp.toString(),
                    yValueMapper: (Data data, _) => data.temp,
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

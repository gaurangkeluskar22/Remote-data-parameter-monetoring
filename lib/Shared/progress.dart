import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

circularProgress() {
  return Container(
    alignment: Alignment.center,
    color: Colors.white,
    padding: EdgeInsets.only(top: 10.0),
    child: SpinKitRing(
      size: 50.0,
      color: Colors.blue,
    ),
  );
}

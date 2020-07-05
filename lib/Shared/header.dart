import 'package:flutter/material.dart';

header(context,
    {bool isAppTitle = false, String titleText, removeback = false}) {
  return AppBar(
    title: Text(
      isAppTitle ? 'RDPM' : titleText,
      style: TextStyle(
          fontFamily: isAppTitle ? 'Signatra' : '',
          fontSize: isAppTitle ? 50 : 22,
          color: Colors.white),
    ),
    automaticallyImplyLeading: removeback ? false : true,
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}

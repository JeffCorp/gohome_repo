import 'package:flutter/material.dart';


class BottomMessageIcon extends Icon{
  BottomMessageIcon(IconData icon) : super(icon);

  int counter = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      // padding: EdgeInsets.only(bottom: 10),
      child: Stack(
            children: <Widget>[
              new IconButton(icon: Icon(Icons.message), onPressed: () {
                // setState(() {
                //   counter = 0;
                // });
              }),
              counter != 0 ? new Positioned(
                right: 11,
                top: 11,
                child: new Container(
                  padding: EdgeInsets.all(2),
                  decoration: new BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 14,
                    minHeight: 2,
                  ),
                  child: Text(
                    '$counter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ) : new Container(),
              // Container(
              //   // margin: EdgeInsets.only(top: 42),
              //   child: Text(
              //   "Messages",
              //   style: TextStyle(fontSize: 12, color: Colors.black54),
              // ),
              // )
            ],
    )
    );
  }

}
import 'package:flutter/material.dart';
import 'package:go_home/services/favoritesServices.dart';
import 'dart:async';
import 'package:quiver/async.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';
import '../services/services.dart';
import '../classes/property.dart';
import '../components/propertyList.dart';
import '../views/eachProperty.dart';

class FavoritesTab extends StatefulWidget {
  FavoritesTab() : super();

  @override
  State<StatefulWidget> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  int _start = 10;
  int _current = 10;

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds;
      });
    });

    sub.onDone(() {
      print("Done");
      sub.cancel();
    });
  }

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  List<Property> properties = List();
  List<Property> filteredProperties = List();

  String typeValue = "House";
  String furnValue = "Furnished";
  String regionValue = "Any Region";
  String statusValue = "Sale";
  String minAmountValue = "Min Amount";
  String maxAmountValue = "Max Amount";

  String number = "5";

  bool isButtonDisabled;
  bool isInitFilter;

  TextEditingController bathroomController = TextEditingController();
  TextEditingController bedroomController = TextEditingController();
  TextEditingController minController = TextEditingController();
  TextEditingController maxController = TextEditingController();

  final snackBar = SnackBar(
    content: Text('Please set the filter'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    startTimer();
    checkAuth();
    isButtonDisabled = true;
    this._memoizer.runOnce(() async {
      FavoritesServices.getProperties().then((propertiesFromServer) {
        setState(() {
          properties = propertiesFromServer;
          filteredProperties = properties;
          print(properties);
        });
      });
    });
  }

  Future<void> reload() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FavoritesTab()));
    return null;
  }

  void filter() {
    setState(() {
      filteredProperties = properties
          .where(
            (p) =>
                p.state.toLowerCase().contains(regionValue.toLowerCase()) &&
                p.propType.toLowerCase().contains(typeValue.toLowerCase()) &&
                p.status.toLowerCase().contains(statusValue.toLowerCase()) &&
                (bedroomController.text.length != 0
                    ? int.parse(p.bedroom) == int.parse(bedroomController.text)
                    : int.parse(p.bedroom) > 0) &&
                (bathroomController.text.length != 0
                    ? int.parse(p.bathroom) ==
                        int.parse(bathroomController.text)
                    : int.parse(p.bathroom) > 0) &&
                (minController.text.length != 0
                    ? int.parse(p.amount) > int.parse(minController.text)
                    : int.parse(p.amount) > 0) &&
                (maxController.text.length != 0
                    ? int.parse(p.amount) < int.parse(maxController.text)
                    : int.parse(p.amount) < 1000000000),
          )
          .toList();
    });
  }

  Future<void> refresh() async {
    setState(() {
      filteredProperties = properties;
    });
    return null;
  }

  bool isAuth = false;

  checkAuth() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool getIsAuth = preferences.getBool("isAuth");
    setState(() {
      isAuth = getIsAuth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isAuth
            ? filteredProperties.length < 1 && _current > 0
                ? Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Color(0xFF79c942),
                  ))
                : filteredProperties.length < 1 && _current == 0
        ? RefreshIndicator(
                        onRefresh: reload,
                        child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 250),
                                  child: Icon(
                                    Icons.priority_high,
                                    size: 40,
                                    color: Colors.red,
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "You don't have any Favorites!!!",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                )
                              ],
                            )))
                    : RefreshIndicator(
                        onRefresh: refresh,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.topRight,
                                child: MaterialButton(
                                    disabledColor: Colors.grey,
                                    color: Colors.white,
                                    elevation: 0,
                                    key: GlobalKey(debugLabel: "sca"),
                                    onPressed: () {
                                      setState(() {
                                        _settingModalBottomSheet(context);
                                      });
                                      print(filteredProperties);
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Icon(Icons.filter_list),
                                        Text(
                                          "Filter",
                                          style: TextStyle(
                                            color: Color(0xFF79c942),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            filteredProperties.length > 0
                                ? Expanded(
                                    child: ListView.builder(
                                      itemCount: filteredProperties.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final item = filteredProperties[index];
                                        return PropertyList(
                                          amount:
                                              filteredProperties[index].amount,
                                          imagePath:
                                              filteredProperties[index].img1,
                                          location:
                                              filteredProperties[index].address,
                                          propId:
                                              filteredProperties[index].prop_id,
                                          region:
                                              filteredProperties[index].region,
                                          saleOrRent:
                                              filteredProperties[index].status,
                                          title:
                                              filteredProperties[index].title,
                                          phone:
                                              filteredProperties[index].phone,
                                          state:
                                              filteredProperties[index].state,
                                          name: filteredProperties[index].name,
                                          email: filteredProperties[index]
                                              .user_email,
                                          isFav: true,
                                          goto: EachProperty(
                                            item: item,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : CircularProgressIndicator(
                                    backgroundColor: Color(0xFF79c942),
                                  ),
                          ],
                        ),
                      )
            : Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 250),
                      child: Icon(
                        Icons.priority_high,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                    Container(
                      child: Text(
                        "You are not logged in!!!",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    MaterialButton(
                      child: Text("Click here to login", style: TextStyle(color: Color(0xFF79c942)),),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ));
  }

  void _settingModalBottomSheet(context) {
    print(typeValue);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          "Filter Property type",
                          style: TextStyle(fontSize: 30),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.black45,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          padding: EdgeInsets.all(5),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: regionValue,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.black),
                            underline: Container(
                              height: 0,
                              color: Colors.black,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                regionValue = newValue;
                              });
                            },
                            items: <String>[
                              'Any Region',
                              'Lagos',
                              'Oyo',
                              'Abuja',
                              'Imo'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.black45,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          padding: EdgeInsets.all(5),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: typeValue,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.black),
                            underline: Container(
                              height: 0,
                              color: Colors.black,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                typeValue = newValue;
                              });
                            },
                            items: <String>['House', 'Office', 'Store', 'Land']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: furnValue,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            underline: Container(
                              height: 0,
                              color: Colors.black,
                            ),
                            style: TextStyle(color: Colors.black),
                            onChanged: (String newValue) {
                              setState(() {
                                furnValue = newValue;
                              });
                            },
                            items: <String>['Furnished', 'Unfurnished']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.black45,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          padding: EdgeInsets.all(5),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.black45,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          padding: EdgeInsets.all(5),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: statusValue,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.black),
                            underline: Container(
                              height: 0,
                              color: Colors.black,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                statusValue = newValue;
                              });
                            },
                            items: <String>['Sale', 'Rent']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.black45,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: bedroomController,
                              decoration: InputDecoration(hintText: "Bedrooms"),
                            )),
                        Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.black45,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: bathroomController,
                            decoration: InputDecoration(hintText: "Bathroom"),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.black45,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: minController,
                            decoration: InputDecoration(hintText: "Min Amount"),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.black45,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: maxController,
                            decoration: InputDecoration(hintText: "Max Amount"),
                          ),
                        ),
                        MaterialButton(
                          height: 50,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          onPressed: () {
                            // setState(() {
                            //   filteredProperties = properties
                            //       .where((p) => p.amount.contains("5"))
                            //       .toList();
                            // });
                            setState(() {
                              isButtonDisabled = false;
                              number = "3";
                            });
                            Navigator.pop(context);
                            filter();
                          },
                          child: Text(
                            "Apply Filter",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Color(0xFF79c942),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}

class isButtonDisabled {}

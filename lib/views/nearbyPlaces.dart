import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

//import 'package:location/location.dart';

import '../components/notificationPill.dart';
import '../services/cityContentServices.dart';
import '../classes/property.dart';
import '../components/propertyList.dart';
import './eachProperty.dart';

class NearbyPlaces extends StatefulWidget {
  final Property item;

  NearbyPlaces({this.item});
  @override
  State<StatefulWidget> createState() => _NearbyPlacestate(item: item);
}

class _NearbyPlacestate extends State<NearbyPlaces> {
  final Property item;

  _NearbyPlacestate({this.item});
  Completer<GoogleMapController> _controller = Completer();

  GoogleMapController mapController;

  double lat, long;
  

  // initial camera position
         CameraPosition _cameraPos;
     // A map of markers
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
        // function to generate random ids
  int generateIds() {
        var rng = new Random();
        var randomInt;      
          randomInt = rng.nextInt(100);
          print(rng.nextInt(100));
        return randomInt;
      }

  static const apiKey = 'AIzaSyACDaIJn21j0iIg3DizilxBRa3uJRuuwKQ';
  static const myLat = 9.060352;
  static const myLong = 7.4514432;

  List nearestLat = List();
  List nearestLong = List();

  static const LatLng _center = const LatLng(myLat, myLong);
  Set<Marker> _markers = {};
  static List<Set<Marker>> _markerList = List();
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    print(await searchNearby("hotel"));
  }
@override
  void initState(){
    super.initState();
    // _onAddMarkerButtonPressed();
    searchandNavigate();
  }

//function to get an address of a given location 
 getPropertyLatLng() async{
   var address = item.description;
   print('hello');
   //replace all white space with plus
  address = address.replaceAll(RegExp(' +'), ' ');
   var query = await Geocoder.local.findAddressesFromQuery(address);
   var locationResponse = query.first; 
   /* var lat = locationResponse.coordinates.latitude;
   var lng = locationResponse.coordinates.longitude; */
   print(locationResponse.coordinates.latitude);
  return locationResponse; 
  
 }

 
  searchNearby(String keyword) async {
    var dio = Dio();
    var url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    var parameters = {
      'key': apiKey,
      'location': '$myLat, $myLong',
      'radius': '800',
      'keyword': keyword
    };

    var response = await dio.get(url, data: parameters);
    setState(() {
      nearestLat = response.data["results"]
        .map<String>(
            (result) => result['geometry']['location']['lat'].toString())
        .toList();
    nearestLong = response.data["results"]
        .map<String>(
            (result) => result['geometry']['location']['lng'].toString())
        .toList();
    });
    
    return response.data["results"]
        .map<String>(
            (result) => result['geometry']['location']['lat'].toString())
        .toList();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  int i = 0;
  _onAddMarkerButtonPressed() {
    if (i < nearestLat.length) {
      _markers.add(
        Marker(
            markerId: MarkerId(_lastMapPosition.toString()),
            position: LatLng(
                double.parse(nearestLat[i]), double.parse(nearestLong[i])),
            
            infoWindow: InfoWindow(
              title: "This is a title",
              snippet: "This is a snippet",
            ),
            icon: BitmapDescriptor.defaultMarker),
      );
      
      _markerList.add(_markers);
      i++;
      _onAddMarkerButtonPressed();
    }
    print(_markers); 
  }
//print(_onAddMarkerButtonPressed());


searchandNavigate() {
    Geolocator().placemarkFromAddress(item.address).then((result) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 10.0)));
          setState(() {
            lat = result[0].position.latitude;
            long = result[0].position.longitude;
          });
    });
  } 

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
    
  }

  Widget button(Function function, IconData icon, var val) {
    return FloatingActionButton(
      heroTag: "button$val",
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

  void _getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    final Map<String, Marker> _markers = {};

    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
      );
      _markers["Current Location"] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearest Locations'),
        backgroundColor: Color(0xFF79c942),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "button3",
        onPressed: searchandNavigate,
        tooltip: 'Get Location',
        child: Icon(Icons.flag),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            //9.060352,7.4514432
            onMapCreated: onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            mapType: _currentMapType,
            // markers: {
            //   markerPointers,
            //   newPointer
            // },
            myLocationEnabled: true,
            onCameraMove: _onCameraMove,
          ),
          /* Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  button(_onMapTypeButtonPressed, Icons.map, 1),
                  SizedBox(
                    height: 16.0,
                  ),
                  button(_onAddMarkerButtonPressed, Icons.add_location, 3),
                ],
              ), 
            ),
          ), */
        ],
      ),
    );
  }
}


//Demo Marker Pointers for testing purposes 

//  Marker markerPointers = Marker(
//     markerId: MarkerId('h1'),
//     position: LatLng(9.060352,7.4514432),
//     infoWindow: InfoWindow(title: 'Banex'),
//     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    
//   );

//   Marker newPointer = Marker(
//     markerId: MarkerId('h1'),
//     position: LatLng(8.060352,7.4514432),
//     infoWindow: InfoWindow(title: 'Banex'),
//     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    
//   );

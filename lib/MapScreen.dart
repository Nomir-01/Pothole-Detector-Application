// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_utils.dart';

class MapScreen extends StatefulWidget {
  final DetailsResult? startPosition;
  final DetailsResult? endPosition;
  const MapScreen({Key? key, this.startPosition, this.endPosition})
      : super(key: key);
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String myDistance = "";
  String myTime = "";
  String myPothole = "";

  late CameraPosition _initialPosition;
  @override
  void initState() {
    getMarkerData();
    super.initState();
    _initialPosition = CameraPosition(
      target: LatLng(widget.startPosition!.geometry!.location!.lat!,
          widget.startPosition!.geometry!.location!.lng!),
      zoom: 14.4746,
    );
    // loadData();
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: const Color.fromRGBO(26, 26, 26, 1),
        points: polylineCoordinates,
        width: 3);
    polylines[id] = polyline;
    setState(() {});
    _getDistance();
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'API KEY',
        PointLatLng(widget.startPosition!.geometry!.location!.lat!,
            widget.startPosition!.geometry!.location!.lng!),
        PointLatLng(widget.endPosition!.geometry!.location!.lat!,
            widget.endPosition!.geometry!.location!.lng!),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _addPolyLine();
  }

  Future<void> _getDistance() async {
    String Url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${widget.startPosition!.geometry!.location!.lat!},${widget.startPosition!.geometry!.location!.lng!}&origins=${widget.endPosition!.geometry!.location!.lat!},${widget.endPosition!.geometry!.location!.lng!}&units=metric&key=API KEY';
    var response = await http.get(
      Uri.parse(Url),
    );
    var body = response.body;
    try {
      Direction direction = Direction.fromJson(jsonDecode(body));
      myDistance = direction.totalDirection.toString();
      myTime = direction.totalTime.toString();
      int count = 0;
      markers.forEach((id, marker) {
        if (isMarkerNearPolyline(marker.position, polylineCoordinates, 2)) {
          count++;
        }
      });
      myPothole = count.toString();
      setState(() {});
    } catch (e) {
      myDistance = "No Drivable Route";
      myTime = "-";
      myPothole = "-";
    }
  }

  bool isMarkerNearPolyline(LatLng markerPosition,
      List<LatLng> polylineCoordinates, double threshold) {
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      double distance = distanceToPolyline(
          markerPosition, polylineCoordinates[i], polylineCoordinates[i + 1]);
      if (distance <= threshold) {
        return true;
      }
    }
    return false;
  }

  double distanceToPolyline(
      LatLng markerPosition, LatLng polylineStart, LatLng polylineEnd) {
    double distance = Geolocator.distanceBetween(
        markerPosition.latitude,
        markerPosition.longitude,
        polylineStart.latitude,
        polylineStart.longitude);
    double heading1 = Geolocator.bearingBetween(
        markerPosition.latitude,
        markerPosition.longitude,
        polylineStart.latitude,
        polylineStart.longitude);
    double heading2 = Geolocator.bearingBetween(polylineStart.latitude,
        polylineStart.longitude, polylineEnd.latitude, polylineEnd.longitude);
    double angle = heading1 - heading2;
    double crossTrackDistance = sin(angle) * distance;
    return crossTrackDistance.abs();
  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  void initMarkers(specify, specifyID) async {
    var markerIDVal = specifyID;
    final MarkerId markerId = MarkerId(markerIDVal);
    final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(specify['Latitude'], specify['Longitude']),
        infoWindow: InfoWindow(title: specifyID),
        icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/pothole.png'));
    setState(() {
      markers[markerId] = marker;
    });
  }

  getMarkerData() async {
    FirebaseFirestore.instance
        .collection('Pothole Location')
        .get()
        .then((myMockData) {
      if (myMockData.docs.isNotEmpty) {
        for (int i = 0; i < myMockData.docs.length; i++) {
          initMarkers(myMockData.docs[i].data(), myMockData.docs[i].id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> _markers = {
      Marker(
          markerId: const MarkerId('Source'),
          position: LatLng(widget.startPosition!.geometry!.location!.lat!,
              widget.startPosition!.geometry!.location!.lng!)),
      Marker(
          markerId: const MarkerId('Destination'),
          position: LatLng(widget.endPosition!.geometry!.location!.lat!,
              widget.endPosition!.geometry!.location!.lng!))
    };
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await getMarkerData();
              _getDistance();
              setState(() {});
            },
            icon: const CircleAvatar(
              backgroundColor: Color.fromRGBO(26, 26, 26, 1),
              child: Icon(
                Icons.refresh,
                color: Color.fromRGBO(230, 230, 230, 1),
              ),
            ),
          )
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const CircleAvatar(
            backgroundColor: Color.fromRGBO(26, 26, 26, 1),
            child: Icon(
              Icons.arrow_back,
              color: Color.fromRGBO(230, 230, 230, 1),
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
        foregroundColor: const Color.fromRGBO(230, 230, 230, 1),
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        title: const Text("Map"),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 800,
            child: GoogleMap(
              polylines: Set<Polyline>.of(polylines.values),
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              initialCameraPosition: _initialPosition,
              markers: Set<Marker>.of(markers.values)..addAll(_markers),
              onMapCreated: (GoogleMapController controller) async {
                Future.delayed(const Duration(milliseconds: 2000), () {
                  controller.animateCamera(CameraUpdate.newLatLngBounds(
                      MapUtils.boundsFromLatLngList(
                          _markers.map((loc) => loc.position).toList()),
                      1));
                  _getPolyline();
                  _getDistance();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(26, 26, 26, 1),
                borderRadius: BorderRadius.all(
                  Radius.circular(40),
                ),
              ),
              width: double.infinity,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    myDistance,
                    style: const TextStyle(
                      color: Color.fromRGBO(230, 230, 230, 1),
                      fontSize: 20,
                    ),
                  ),
                  const Icon(
                    Icons.circle,
                    color: Color.fromRGBO(230, 230, 230, 1),
                    size: 12,
                  ),
                  Text(
                    myTime,
                    style: const TextStyle(
                      color: Color.fromRGBO(230, 230, 230, 1),
                      fontSize: 20,
                    ),
                  ),
                  const Icon(
                    Icons.circle,
                    color: Color.fromRGBO(230, 230, 230, 1),
                    size: 12,
                  ),
                  Text(
                    myPothole,
                    style: const TextStyle(
                      color: Color.fromRGBO(230, 230, 230, 1),
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Direction {
  late final String totalDirection;
  late final String totalTime;
  Direction({
    required this.totalDirection,
    required this.totalTime,
  });
  factory Direction.fromJson(Map<String, dynamic> json) {
    String distance = '';
    String time = '';
    final data = Map<String, dynamic>.from(json['rows'][0]);
    distance = data['elements'][0]['distance']['text'];
    time = data['elements'][0]['duration']['text'];
    return Direction(
      totalDirection: distance,
      totalTime: time,
    );
  }
}

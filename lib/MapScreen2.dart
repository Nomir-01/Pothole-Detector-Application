import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'SearchScreen.dart';

class MapScreen2 extends StatefulWidget {
  const MapScreen2({Key? key}) : super(key: key);

  @override
  State<MapScreen2> createState() => _MapScreen2State();
}

class _MapScreen2State extends State<MapScreen2> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(24.923816, 67.098588),
    zoom: 11.5,
  );

  final Completer<GoogleMapController> _googleMapController = Completer();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  void initMarkers(specify, specifyID) async {
    var markerIDVal = specifyID;
    final MarkerId markerId = MarkerId(markerIDVal);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(specify['Latitude'], specify['Longitude']),
      infoWindow: InfoWindow(title: specifyID),
      icon: await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/pothole.png'),
    );
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

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error$error");
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    getMarkerData();
    super.initState();
    // loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await getMarkerData();
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
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
        title: const Text("Map"),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 800,
            child: GoogleMap(
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              initialCameraPosition: _initialCameraPosition,
              markers: Set<Marker>.of(markers.values),
              onMapCreated: (GoogleMapController controller) {
                _googleMapController.complete(controller);
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(230, 230, 230, 1)),
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(26, 26, 26, 1)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Where To',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
        foregroundColor: const Color.fromRGBO(230, 230, 230, 1),
        onPressed: () async {
          getUserCurrentLocation().then((value) async {
            CameraPosition cameraPosition = CameraPosition(
                zoom: 14, target: LatLng(value.latitude, value.longitude));
            final GoogleMapController controller =
                await _googleMapController.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });
        },
        child: const Icon(Icons.navigation),
      ),
    );
  }
}

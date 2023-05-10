import 'dart:async';
import 'dart:developer';
import 'dart:math' show cos, sqrt, asin, distanceBetween;

import 'package:geolocator/geolocator.dart' as Geolocator;

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/core/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as Location;
import 'dart:ui' as ui;

import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../view-model/google_map_controller.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  late GoogleMapProvider googleMapProvider;
  @override
  void initState() {
    googleMapProvider = Provider.of<GoogleMapProvider>(context, listen: false);
    googleMapProvider.getCurrentLocation();
    googleMapProvider.getPolyPoints();
    googleMapProvider.estimateTravelTime([googleMapProvider.center]);
    googleMapProvider.loadCurrentLocationIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) async {

    // });

    return Consumer<GoogleMapProvider>(
      builder: (context, value, child) {
        log('curernt location from UI ${value.currentLocation}');
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Accident",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          body: value.currentLocation == null
              ? const Center(child: Text("Loading"))
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: value.center,
                        zoom: 14.5,
                      ),
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId("route"),
                          points: value.polylineCoordinates,
                          color: primaryColor,
                          width: 6,
                        ),
                      },
                      markers: {
                        Marker(
                            markerId: const MarkerId("currentLocation"),
                            position: LatLng(
                              value.currentLocation!.latitude,
                              value.currentLocation!.longitude,
                            ),
                            icon: value.currentLocationIcon),
                        Marker(
                          markerId: const MarkerId("source"),
                          position: value.sourceLocation,
                        ),
                        Marker(
                          markerId: const MarkerId("destination"),
                          position: value.destination,
                        ),
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              value.estimatedTime == null
                                  ? "Calculating..."
                                  : "Estimated time: ${value.estimatedTime!.inMinutes} mins",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text("Cancel"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

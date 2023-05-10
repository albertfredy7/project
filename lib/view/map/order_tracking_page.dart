import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mao/core/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';

import '../../view-model/map/google_map_controller.dart';

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
    googleMapProvider.estimateTravelTime(
        [googleMapProvider.sourceLocation, googleMapProvider.destination]);
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
                      polylines: value.noEmergency
                          ? const <Polyline>{}
                          : {
                              Polyline(
                                polylineId: const PolylineId("route"),
                                points: value.polylineCoordinates,
                                color: primaryColor,
                                width: 6,
                              ),
                            },
                      onTap: (argument) {
                        value.onMapTapped(argument);
                      },
                      markers: {
                        Marker(
                            markerId: const MarkerId("currentLocation"),
                            position: const LatLng(
                                10.727631644072261, 76.28998265434156
                                // value.currentLocation!.latitude,
                                // value.currentLocation!.longitude,
                                ),
                            icon: value.currentLocationIcon),
                        if (!value.noEmergency)
                          Marker(
                            markerId: const MarkerId("source"),
                            position: value.sourceLocation,
                          ),
                        if (!value.noEmergency)
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
                              value.noEmergency
                                  ? 'No Emergency'
                                  : value.estimatedTime == null
                                      ? "Calculating..."
                                      : "Estimated time: ${value.estimatedTime!.inMinutes} mins",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            !value.noEmergency
                                ? ElevatedButton(
                                    onPressed: () {
                                      value.onCancel();
                                    },
                                    child: const Text("Cancel"),
                                  )
                                : const SizedBox(
                                    height: 50,
                                  )
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

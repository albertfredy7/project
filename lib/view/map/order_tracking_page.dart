import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mao/Models/location_model.dart';
import 'package:google_mao/core/constants.dart';
import 'package:google_mao/functions/app_functions.dart';
import 'package:google_mao/view-model/auth/authentication_controller.dart';
import 'package:google_mao/view/auth/phone_number_authentication.dart';
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
    final authProvider =
        Provider.of<AuthneticationController>(context, listen: false);

    return Consumer<GoogleMapProvider>(
      builder: (context, value, child) {
        log('curernt location from UI ${value.currentLocation}');
        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () async {
                String locationresponseString =
                    await AppApiFunctions.fetchData();
                value.setInspectedAsFalse();

                if (locationresponseString != "errror") {
                  print("not error received");
                  locationResponseModelClassFromJson(locationresponseString);
                  // checking the conditions
                  if (locationResponseModelClassFromJson(locationresponseString)
                          .longitude
                          .isNotEmpty &&
                      locationResponseModelClassFromJson(locationresponseString)
                          .latitude
                          .isNotEmpty) {
                    // setting destination value in the provider class

                    await value.setDestinationValue(
                        longitude: double.parse(
                            locationResponseModelClassFromJson(
                                    locationresponseString)
                                .longitude),
                        latitude: double.parse(
                            locationResponseModelClassFromJson(
                                    locationresponseString)
                                .latitude));

                    // calling the refreshing button
                    value.onRefreshedAndFoundLocation(
                        longitude: locationResponseModelClassFromJson(
                                locationresponseString)
                            .longitude,
                        latitude: locationResponseModelClassFromJson(
                                locationresponseString)
                            .latitude);
                  }
                }
              },
              child: Image.asset(
                appIcon,
                height: 20,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              IconButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text(
                            'Are you sure you want to logout from this app?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () async {
                                final status =
                                    await authProvider.logOut(context);

                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PhoneAuth(),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Yes')),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout)),
            ],
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
                      // onTap: (argument) {
                      //   value.onMapTapped(argument);
                      // },
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
                          height: value.emergencyShowingContainerHeight,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              )),
                          padding: const EdgeInsets.all(16),
                          child:
                              // Row(
                              //   mainAxisAlignment: value.noEmergency
                              //       ? MainAxisAlignment.center
                              //       : MainAxisAlignment.spaceBetween,
                              //   children: [
                              // Text(
                              //   value.noEmergency
                              //       ? 'No Emergency'
                              //       : value.estimatedTime == null
                              //           ? "Calculating..."
                              //           : "Estimated time: ${value.estimatedTime!.inMinutes} mins",
                              //   style: const TextStyle(
                              //     fontSize: 18,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              // !value.noEmergency
                              //     ? ElevatedButton(
                              //         onPressed: () {
                              //           value.onCancel();
                              //         },
                              //         child: const Text("Cancel"),
                              //       )
                              //     : const SizedBox(
                              //         height: 50,
                              //       )
                              //   ],
                              // ),
                              SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  value.noEmergency
                                      ? "No Accidents Detected"
                                      : "Emergency Alert !",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 30),
                                Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.only(left: 20, right: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        value.estimatedTime == null
                                            ? "Calculating..."
                                            : "Estimmated Time : ${value.estimatedTime!.inMinutes} min",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      value.inspectButtonPressed
                                          ? Container()
                                          : GestureDetector(
                                              onTap: () {
                                                print("inspact button tapped");
                                                value.onInspectButtonTapped();
                                                value.setInspectedAsTrue();
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Center(
                                                  child: Text(
                                                    "Inspect",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Color.fromARGB(
                                                            255, 255, 56, 106)),
                                                  ),
                                                ),
                                              ),
                                            )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

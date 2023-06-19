// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';
import 'package:geolocator/geolocator.dart' as Geolocator;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/core/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as Location;

class GoogleMapProvider extends ChangeNotifier {
  final Completer<GoogleMapController> controller = Completer();

  LatLng sourceLocation = LatLng(10.727631644072261, 76.28998265434156);
  LatLng destination = LatLng(10.727631654072261, 76.29998265434156);
  // LatLng markerPosititon = LatLng(10.727631644072261, 76.28998265434156);

  late BitmapDescriptor currentLocationIcon;
  LatLng center = const LatLng(10.727631644072261, 76.28998265434156);

  List<LatLng> polylineCoordinates = [];
  Geolocator.Position? currentLocation;
  Duration? estimatedTime;
  bool isLoading = false;
  bool noEmergency = true;
  PolylinePoints polylinePoints = PolylinePoints();
  double distance = 0;
  double emergencyShowingContainerHeight = 60;
  bool inspectButtonPressed = false;

  // onMapTapped(LatLng argument) async {
  //   noEmergency = false;
  //   destination = argument;
  //   // polylineCoordinates = [destination, sourceLocation];
  //   await estimateTravelTime(polylineCoordinates);
  //   await getPolyPoints();
  //   notifyListeners();
  // }

  onInspectButtonTapped() async {
    print("updating location");

    // destination = LatLng(double.parse(latitude), double.parse(longitude));
    polylineCoordinates.clear();

    print("printing the currrent and destination location");
    print("$destination $sourceLocation");
    polylineCoordinates
        .addAll([destination, LatLng(10.727552099880127, 76.28994973951815)]);

    await estimateTravelTime(polylineCoordinates);
    await getPolyPoints();
    notifyListeners();
  }

  setDestinationValue({required double longitude, required double latitude}) {
    destination = LatLng(latitude, longitude);
    notifyListeners();
  }

  onRefreshedAndFoundLocation(
      {required String longitude, required String latitude}) async {
    print("updating location");
    noEmergency = false;
    emergencyShowingContainerHeight = 160;

    destination = LatLng(double.parse(latitude), double.parse(longitude));
    // sourceLocation = destination; // Set the source location as the destination

    // Clear the existing polylineCoordinates list
    polylineCoordinates.clear();

    // Add the destination coordinate to the polylineCoordinates list
    // polylineCoordinates.add(destination);

    // Notify listeners to update the UI
    notifyListeners();
  }

  setInspectedAsTrue() {
    inspectButtonPressed = true;
    notifyListeners();
  }

  setInspectedAsFalse() {
    inspectButtonPressed = false;
    notifyListeners();
  }
  //

  Future<void> showPolylinesToLocation(LatLng location) async {
    // // Clear the existing polylineCoordinates list
    // polylineCoordinates.clear();

    // // Set the destination coordinate
    // destination = location;

    // // Add the source and destination coordinates to the polylineCoordinates list
    // polylineCoordinates.addAll([sourceLocation, destination]);

    await estimateTravelTime(polylineCoordinates);
    await getPolyPoints();

    // // Notify listeners to update the UI
    notifyListeners();
  }

  onCancel() {
    polylineCoordinates.clear();
    estimatedTime = Duration.zero;
    noEmergency = true;
    emergencyShowingContainerHeight = 60;

    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    Location.Location location = Location.Location();
    bool isLocationEnabled = await location.serviceEnabled();
    log("isLocationEnabled : $isLocationEnabled");

    if (!isLocationEnabled) {
      bool enableResult = await location.requestService();
      if (!enableResult) {
        return;
      }
    }

    Location.PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == Location.PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != Location.PermissionStatus.granted) {
        return;
      }
    }
    // log("location permission status : $permissionStatus");

    Geolocator.Geolocator geolocator = Geolocator.Geolocator();
    Geolocator.Position position =
        await Geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: Geolocator.LocationAccuracy.high);
    // log('current position : $position');

    currentLocation = position;
    notifyListeners();
    center = LatLng(10.727631644072261, 76.28998265434156);
    // LatLng(position.latitude, position.longitude);
    notifyListeners();
  }

  Future<Duration> estimateTravelTime(List<LatLng> polylineCoordinates) async {
    if (estimatedTime != null) {
      estimatedTime = null;
      distance = 0;
      notifyListeners();
    }

    // log('poly length ; ${polylineCoordinates}');

    for (int i = 0; i < polylineCoordinates.length; i++) {
      // log('loop started');
      // log('PLY ${polylineCoordinates[i]}');
      LatLng start = polylineCoordinates[0];
      LatLng end = polylineCoordinates[1];
      distance += Geolocator.Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
    }

    // log('distance $distance');

    Geolocator.Position currentPosition =
        await Geolocator.Geolocator.getCurrentPosition(
      desiredAccuracy: Geolocator.LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );

    double averageSpeed = 30;
    double timeToDestinationInHours = Geolocator.Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          polylineCoordinates.last.latitude,
          polylineCoordinates.last.longitude,
        ) /
        (averageSpeed * 1000);

    log('$distance ${currentPosition.latitude}, ${currentPosition.longitude},${polylineCoordinates.last.latitude},${polylineCoordinates.last.longitude},}');
    int timeToDestinationInMinutes = (timeToDestinationInHours * 60).round();

    double estimatedTimeInHours = distance / (averageSpeed * 1000);
    int estimatedTimeInMinutes = (estimatedTimeInHours * 60).round();

    log('$estimatedTimeInHours = ($distance / ($averageSpeed * 1000) \n time in hour :$estimatedTimeInHours \n time in minute : $estimatedTimeInMinutes');

    estimatedTime = Duration(
        hours: estimatedTimeInHours.toInt(), minutes: estimatedTimeInMinutes);
    notifyListeners();
    log('estimated time : $estimatedTime');

    return Duration(
        minutes: estimatedTimeInMinutes + timeToDestinationInMinutes);
  }

  Future<void> getPolyPoints() async {
    if (polylineCoordinates.isNotEmpty) {
      polylineCoordinates.clear();
      notifyListeners();
    }

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      notifyListeners();
    }
  }

  Future<void> loadCurrentLocationIcon() async {
    const config = ImageConfiguration(size: Size(20, 20));
    final BitmapDescriptor bitmapDescriptor =
        await BitmapDescriptor.fromAssetImage(
      config,
      'assets/icons/source_icon.png',
    );

    currentLocationIcon = bitmapDescriptor;
    notifyListeners();
  }
}

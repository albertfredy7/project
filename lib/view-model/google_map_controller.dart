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

  LatLng sourceLocation = LatLng(10.495421071158342, 76.24565805104527);
  LatLng destination = LatLng(10.50038993265248, 76.25123483398062);

  late BitmapDescriptor currentLocationIcon;
  LatLng center = const LatLng(40.7128, -74.0060);

  List<LatLng> polylineCoordinates = [];
  Geolocator.Position? currentLocation;
  Duration? estimatedTime;
  bool isLoading = false;

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
     log("location permission status : $permissionStatus");

    Geolocator.Geolocator geolocator = Geolocator.Geolocator();
    Geolocator.Position position =
        await Geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: Geolocator.LocationAccuracy.high);
    log('current position : $position');

    currentLocation = position;
    notifyListeners();
    center = LatLng(position.latitude, position.longitude);
    notifyListeners();
  }

  Future<Duration> estimateTravelTime(List<LatLng> polylineCoordinates) async {
    double distance = 0;

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      LatLng start = polylineCoordinates[i];
      LatLng end = polylineCoordinates[i + 1];
      distance += Geolocator.Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
    }

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

    int timeToDestinationInMinutes = (timeToDestinationInHours * 60).round();

    double estimatedTimeInHours = distance / (averageSpeed * 1000);
    int estimatedTimeInMinutes = (estimatedTimeInHours * 60).round();

    estimatedTime = Duration(
        hours: estimatedTimeInHours.toInt(), minutes: estimatedTimeInMinutes);
    notifyListeners();
    log('estimated time : $estimatedTime');

    return Duration(
        minutes: estimatedTimeInMinutes + timeToDestinationInMinutes);
  }

  Future<void> getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
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

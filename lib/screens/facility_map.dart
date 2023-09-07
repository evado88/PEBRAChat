import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:twyshe/classes/facility.dart';
import 'package:twyshe/screens/task_result.dart';
import 'package:twyshe/utils/api.dart';

class FacilityMap extends StatefulWidget {
  const FacilityMap({super.key});

  @override
  State<FacilityMap> createState() => _FacilityMapState();
}

class _FacilityMapState extends State<FacilityMap> {
  List<TwysheFacility> items = [];
  Set<Marker> markers = {};

  bool loading = true;
  bool succeeded = false;

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(-15.3923098, 28.3259236);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    Future.delayed(
        const Duration(milliseconds: 800),
        () => controller.animateCamera(CameraUpdate.newLatLngBounds(
            boundsFromLatLngList(markers.map((loc) => loc.position).toList()),
            1)));
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      loading = true;
    });

    TwysheTaskResult rs = await TwysheAPI.fetchTwysheFacilities();

    if (rs.succeeded) {
      setState(() {
        items = rs.items as List<TwysheFacility>;
        markers = items
            .map<Marker>(
              (f) => Marker(
                  markerId: MarkerId(f.facilityId.toString()),
                  position: LatLng(f.facilityLat, f.facilityLon),
                  infoWindow: InfoWindow(
                    title: f.facilityName,
                    snippet: f.facilityAddress,
                  )),
            )
            .toSet();

        succeeded = true;
        loading = false;
      });
    } else {
      setState(() {
        items = [];
        succeeded = false;
        loading = false;
      });
    }
  }

  boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Facilities Map'),
        elevation: 2,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 13.0,
        ),
        markers: markers,
      ),
    );
  }
}

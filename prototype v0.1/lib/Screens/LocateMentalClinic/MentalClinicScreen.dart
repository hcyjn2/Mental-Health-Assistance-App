import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:main_menu/components/MentalHealthClinic/Map.dart';
import 'package:main_menu/components/MenuFunctions/MenuFunction.dart';
import 'package:main_menu/components/MenuFunctions/SwipeablePageWidget.dart';
import 'package:main_menu/constants.dart';
import 'package:main_menu/models/place.dart';
import 'package:main_menu/services/marker_service.dart';
import 'package:main_menu/services/places_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MentalClinicMap extends StatefulWidget {
  @override
  _MentalClinicMapState createState() => _MentalClinicMapState();
}

class _MentalClinicMapState extends State<MentalClinicMap> with MenuFunction {
  //initialize variables
  double latitude;
  double longitude;
  GoogleMapController mapController;
  Future<Map> mapFuture;
  List<Place> places;
  List<Marker> markers;
  BitmapDescriptor markerIcon;
  bool locationWorks = false;

  //map widget error window
  void onGeolocatorProblemAction(BuildContext context, String problemText) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            problemText,
            style:
                kThickFont.copyWith(fontSize: 19, fontWeight: FontWeight.w100),
            textAlign: TextAlign.center,
          ),
          content: MaterialButton(
            elevation: 5.0,
            color: Colors.grey[400],
            child: Text(
              'OKAY',
              style: kThickFont.copyWith(fontSize: 17),
            ),
            onPressed: () async {
              returnBack(context);
            },
          ),
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  //grab device location data
  Future<Map> initData() async {
    Map map = Map(places: [], markers: []);
    LocationPermission permission;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onGeolocatorProblemAction(context, servicesDisabled);
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        onGeolocatorProblemAction(context, permissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      onGeolocatorProblemAction(context, permissionDeniedForever);
    } else {
      map = await initializeMap();
      locationWorks = true;
    }

    return map;
  }

  //initialize map widget
  Future<Map> initializeMap() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'assets/Images/marker.png');

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      latitude = position.latitude;
      longitude = position.longitude;
      places = (latitude != null && longitude != null)
          ? await PlacesService().getPlaces(latitude, longitude, markerIcon)
          : null;
      markers = (places != null) ? MarkerService().getMarkers(places) : null;
    } catch (e) {
      print(e);
    }
    return Map(places: places, markers: markers);
  }

  //navigate to the google map/browser with the given coordinates
  void _launchMapsUrl(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url))
      await launch(url);
    else
      throw 'Could not launch $url';
  }

  @override
  void initState() {
    mapFuture = initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SwipeablePageWidget(
        onSwipeCallback: () {
          returnBack(context);
        },
        child: Scaffold(
          body: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.09,
                width: double.infinity,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10.0),
                ),

                //page title
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('Nearby Mental Clinics',
                      textAlign: TextAlign.center,
                      style: kThickFont.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent)),
                ),
              ),

              //map widget with nearby mental clinics as the way points on the map
              FutureBuilder(
                future: mapFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      locationWorks) {
                    return Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.55,
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 15),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: GoogleMap(
                                markers: Set<Marker>.of(snapshot.data.markers),
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(latitude, longitude),
                                  zoom: 10,
                                ),
                              ),
                            ),
                          ),
                        ),

                        //bottom list view which shows the name and details about the mental clinics nearby
                        Container(
                          child: ListView.builder(
                            itemCount: snapshot.data.places.length,
                            itemBuilder: (context, index) {
                              double distance;
                              if (snapshot.data.places[index].geometry.location
                                      .lat !=
                                  null)
                                distance = Geolocator.distanceBetween(
                                    latitude,
                                    longitude,
                                    snapshot.data.places[index].geometry
                                        .location.lat,
                                    snapshot.data.places[index].geometry
                                        .location.lng);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 8.0),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    title: Text(
                                      snapshot.data.places[index].name,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    subtitle: RichText(
                                      text: TextSpan(
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 11),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    '${snapshot.data.places[index].vicinity} \u00b7  '),
                                            TextSpan(
                                                style: kThickFont.copyWith(
                                                    fontSize: 9),
                                                text:
                                                    '${(distance / 1000).toStringAsFixed(2)}km')
                                          ]),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        _launchMapsUrl(
                                            snapshot.data.places[index].geometry
                                                .location.lat,
                                            snapshot.data.places[index].geometry
                                                .location.lng);
                                      },
                                      alignment: Alignment.centerRight,
                                      icon: Icon(
                                        Icons.assistant_navigation,
                                        color: Colors.blueAccent,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          height: MediaQuery.of(context).size.height * 0.26,
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ],
                    );
                  } else {
                    //loading indicator for map widget
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Loading...',
                            style: kThickFont.copyWith(fontSize: 15),
                          ),
                        ),
                        Container(
                          child: LinearProgressIndicator(),
                          width: 90,
                          height: 8,
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

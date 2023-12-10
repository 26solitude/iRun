import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:irun/login/login_api.dart';

class RoutePage extends StatefulWidget {
  final Map<String, dynamic> routeData;

  const RoutePage({Key? key, required this.routeData}) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  Set<Marker> _markers = {};
  final User? user = auth.currentUser;



  @override
  void initState() {
    super.initState();
    successful();
    _createPolylines();
  }

  Future<void> successful() async {
    Map<String, List<String>> successfulMissions = widget.routeData['successfulMissions'];
  }


  void _createPolylines() {
    List<dynamic> coordinatesListDynamic = widget.routeData['route'];

    // List<dynamic>을 List<Map<String, dynamic>>으로 변환
    List<Map<String, dynamic>> coordinatesList =
        coordinatesListDynamic.cast<Map<String, dynamic>>();

    print(coordinatesList);

    polylineCoordinates = coordinatesList.map((point) {
      double lat = (point['latitude'] as num).toDouble();
      double lng = (point['longitude'] as num).toDouble();
      return LatLng(lat, lng);
    }).toList();

    // 시작점과 종료점 마커 추가
    Marker startMarker = Marker(
      markerId: MarkerId('start'),
      position: polylineCoordinates.first,
      infoWindow: InfoWindow(title: 'Start'),
    );

    Marker endMarker = Marker(
      markerId: MarkerId('end'),
      position: polylineCoordinates.last,
      infoWindow: InfoWindow(title: 'End'),
    );

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          visible: true,
          points: polylineCoordinates,
          color: Colors.red,
          width: 8,
        ),
      );

      _markers.add(startMarker);
      _markers.add(endMarker);
    });
  }

  @override
  Widget build(BuildContext context) {

    Timestamp timestamp = widget.routeData['timestamp'] as Timestamp;
    DateTime dateTime = timestamp.toDate();
    String formattedDateTime = DateFormat('yyy/MM/dd HH:mm').format(dateTime);

    Map<String, dynamic> data = widget.routeData['successfulMissions'];
    Map<String, List<dynamic>> successfulMissions = {};

    data.forEach((key, value) {
      successfulMissions[key] = value.cast<dynamic>();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '기록 상세',
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              '${formattedDateTime}', // 원하는 텍스트로 변경
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 300,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                rootBundle
                    .loadString('assets/map/mapstyle.json')
                    .then((String mapStyle) {
                  controller.setMapStyle(mapStyle);
                  _mapController = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                target: polylineCoordinates.isNotEmpty
                    ? polylineCoordinates.first
                    : LatLng(0, 0),
                zoom: 14,
              ),
              polylines: _polylines,
              markers: _markers,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '${widget.routeData['duration'].substring(1)}', // 원하는 두 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '시간', // 원하는 첫 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '${widget.routeData['pace']}', // 원하는 두 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '페이스', // 원하는 첫 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '${widget.routeData['distance']}km', // 원하는 두 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '거리', // 원하는 첫 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '${widget.routeData['caloriesBurned']}', // 원하는 두 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '칼로리', // 원하는 첫 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Center( // "성공한 미션"을 Center 위젯으로 감싸서 중앙 정렬
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                '성공한 미션',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '거리', // 원하는 두 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      successfulMissions['거리']!.first,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '시간', // 원하는 두 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      successfulMissions['시간']!.join(','),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '페이스', // 원하는 두 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      successfulMissions['페이스']!.join(','),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 여기에 추가적인 위젯을 배치할 수 있습니다.
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

}


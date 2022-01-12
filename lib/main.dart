import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.43296265331129, -122.08832357078792),
    zoom: 16.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   print("WidgetsBinding");

    // });

    // _add();
  }

  void _add() async {
    // var markerIdVal = MyWayToGenerateId();

    BitmapDescriptor testIcon = await getCustomIcon();

    final MarkerId markerId = MarkerId(DateTime.now().toString());

    // creating a  MARKER
    final Marker marker = Marker(
      markerId: markerId,
      draggable: false,
      icon: testIcon,
      position: const LatLng(37.43296265331129, -122.08832357078792
          // 37.42796133580664,
          // -122.085749655962,
          ),
      // infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    );

    setState(() {
      // adding a  marker to map
      markers[markerId] = marker;
    });
  }

  GlobalKey iconKey = GlobalKey();

  Widget customMarker() {
    return RepaintBoundary(
      key: iconKey,
      child:  ClipPath(
            clipper: ConvexClipPath(),
            child: Container(
              // width: 50,
              // height: 30,
              width: 100,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.green,
                // borderRadius:  BorderRadius.circular(4),
                shape:  BoxShape.rectangle,
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "المنصوره",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

 

  Future<Uint8List?> _capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
          iconKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData?.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes!);
      print("=====xx=======" + pngBytes.toString());
      print("=====xx=======" + bs64.toString());
      print(bs64);
      setState(() {});
      return pngBytes;
    } catch (e) {
      print("errororororororoorr");
      print(e);
    }
  }

  Future<BitmapDescriptor> getCustomIcon() async {
    Uint8List? imageData = await _capturePng();
    // log("testIcon set");
    print("=-=xxxxxxxxxxxxx-=-=> $imageData");
    return BitmapDescriptor.fromBytes(imageData!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Scaffold(
        body: Stack(
          children: [
            customMarker(),
            GoogleMap(
              mapType: MapType.normal,
              markers: Set<Marker>.of(markers.values),
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
        
          ],
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: _goToTheLake,
        //   label: const Text('Show Marker'),
        //   icon: const Icon(Icons.map_outlined),
        // ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        label: const Text('Show Marker'),
        icon: const Icon(Icons.map_outlined),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}

class ConvexClipPath extends CustomClipper<Path> {
  double factor = 55;
  @override
  Path getClip(Size size) {
    

    Path path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 5);
    path.lineTo((size.width / 2) - 5, size.height - 5);
    path.lineTo(size.width / 2, size.height);
    path.lineTo((size.width / 2) + 5, size.height - 5);
    path.lineTo(size.width , size.height - 5);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

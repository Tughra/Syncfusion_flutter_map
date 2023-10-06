import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

void main() {
  return runApp(MapsApp());
}

/// This widget will be the root of application.
class MapsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maps Demo',
      home: MyHomePage(
        key: UniqueKey(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  _MyHomePageState();

  MapLatLng pos1 = const MapLatLng(17.5, 106.6);
  MapLatLng pos2 = const MapLatLng(-19.6, 18.1);
  MapLatLng markerPosition = const MapLatLng(41.0, 28.7);
  late MapZoomPanBehavior _zoomPanBehavior;
  late List<Model> _data;
  late MapShapeSource _mapSource;
  late final AnimationController controller;
  List<MapSublayer>? sublayers;
  late final Animation<double> animation;

  MapShapeLayerController mapShapeLayerController = MapShapeLayerController();

  @override
  void initState() {
    // controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    // animation = CurvedAnimation(parent: controller, curve: Curves.linear);
    _zoomPanBehavior = MapZoomPanBehavior(
      focalLatLng: const MapLatLng(41.0, 28.7),
      enablePanning: false,
      enablePinching: false,
      toolbarSettings: const MapToolbarSettings(position: MapToolbarPosition.topLeft),
      zoomLevel: 8,
    );
    _data = const <Model>[
      Model('Turkey', Color.fromRGBO(255, 215, 0, 1.0), 'Turkey'),
      Model('Australia', Color.fromRGBO(72, 209, 204, 1.0), 'Australia'),
    ];

    _mapSource = MapShapeSource.asset(
      'assets/world_map.json',
      shapeDataField: '', //name
      // dataCount: _data.length,
      // primaryValueMapper: (int index) => _data[index].state,
      // dataLabelMapper: (int index) => _data[index].stateCode,
      // shapeColorValueMapper: (int index) => _data[index].color,
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(60, 61, 192, 1),
      floatingActionButton: Row(
        children: [
          FloatingActionButton(
            onPressed: () {
              _zoomPanBehavior.focalLatLng = const MapLatLng(-38.45, -63.59);
              //_zoomPanBehavior.zoomLevel=10;
              focusPoint(const MapLatLng(41.0, 28.7), const MapLatLng(-38.45, -63.59));
            },
            tooltip: 'Zoom In',
            child: const Icon(Icons.arrow_forward),
          ),
          FloatingActionButton(
            onPressed: () {
              _zoomPanBehavior.focalLatLng = const MapLatLng(41.0, 28.7);
              focusPoint(const MapLatLng(-20.86, 151.2), const MapLatLng(41.0, 28.7));
            },
            tooltip: 'Zoom In',
            child: const Icon(Icons.arrow_back),
          ),
        ],
      ),
      body: Center(
        child: SfMaps(
          layers: <MapShapeLayer>[
            MapShapeLayer(
              color: Colors.teal.shade400,
              controller: mapShapeLayerController,
              zoomPanBehavior: _zoomPanBehavior,
              source: _mapSource,
              showDataLabels: true,
              //legend:const MapLegend(MapElement.shape),
              sublayers: sublayers,
              tooltipSettings: MapTooltipSettings(color: Colors.grey[700], strokeColor: Colors.white, strokeWidth: 2),
              strokeColor: Colors.white,
              strokeWidth: 0.5,
              initialMarkersCount: 1,
              markerBuilder: (BuildContext ctx, int index) => MapMarker(
                latitude: markerPosition.latitude,
                longitude: markerPosition.longitude,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.asset(
                      "assets/balloon.png",
                      width: 60,
                      height: 60,
                    ),
                    PulseAnimationDemo(
                      size: 32,
                    ),
                  ],
                ),
              ),
              shapeTooltipBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _data[index].stateCode,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
              dataLabelSettings: MapDataLabelSettings(
                textStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.bodySmall!.fontSize),
              ),
            )
          ],
        ),
      ),
    );
  }

  focusPoint(MapLatLng from, MapLatLng to) {
    final Tween<double> latTween = Tween<double>(begin: from.latitude, end: to.latitude);
    final Tween<double> lngTween = Tween<double>(begin: from.longitude, end: to.longitude);
    final AnimationController controller = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this);
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.linear);
    controller.addListener(() {
      markerPosition = MapLatLng(latTween.evaluate(animation), lngTween.evaluate(animation));
      mapShapeLayerController.clearMarkers();
      mapShapeLayerController.insertMarker(0);
      sublayers = <MapSublayer>[
        MapLineLayer(
          animation: animation,
          lines: [
            MapLine(
              from: from,
              to: to,
              dashArray: [4, 4],
            )
          ].toSet(),
          color: Colors.white,
        ),
        /*
        MapLineLayer(
        arcs:[MapArc(from: from, to: to)].toSet(),
        color: Colors.blue,
        animation: animation,
      )
         */
      ];
      //_zoomPanBehavior.focalLatLng =  MapLatLng(latTween.evaluate(animation), lngTween.evaluate(animation));
    });
    setState(() {});
    animation.addStatusListener((status) {
      print("AnimationStatus => $status");
      if (status == AnimationStatus.completed) {
        setState(() {});
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }
}

/// Collection of Australia state code data.
class Model {
  /// Initialize the instance of the [Model] class.
  const Model(this.state, this.color, this.stateCode);

  /// Represents the Australia state name.
  final String state;

  /// Represents the Australia state color.
  final Color color;

  /// Represents the Australia state code.
  final String stateCode;
}

///ff
abstract class X extends StatelessWidget {
  ///DD
  const X({required this.a});

  ///DD
  final String a;
}

class PulseAnimationDemo extends StatefulWidget {
  const PulseAnimationDemo({Key? key, required this.size}) : super(key: key);
  final double size;

  @override
  _PulseAnimationDemoState createState() => _PulseAnimationDemoState();
}

class _PulseAnimationDemoState extends State<PulseAnimationDemo> with TickerProviderStateMixin {
  late AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);


    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

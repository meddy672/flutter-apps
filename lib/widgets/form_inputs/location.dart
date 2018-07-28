import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import '../helpers/ensure_visible.dart';

class LocationInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocationInput();
  }
}

class _LocationInput extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  Uri _staticMapUri;

  @override
    void initState() {
      _addressInputFocusNode.addListener(_updateLocation);
      getStaticMap();
      super.initState();
    }

    void getStaticMap() {
      final StaticMapProvider staticMapProvider = StaticMapProvider('AIzaSyBPqvb9-5ytCObTnJE3J5zw4wSP-yv1UQ4');
      final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers([
        Marker('position', 'Position', 41.40338, 2.17403),
      ],
      center: Location(41.40338, 2.17403),
      width: 500,
      height: 300,
      maptype: StaticMapViewType.roadmap
      );
      setState(() {
           _staticMapUri = staticMapUri;  
      });
    }

  @override
  void dispose(){
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }
  void _updateLocation(){

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            focusNode: _addressInputFocusNode,
          ),
        ),
        SizedBox(height: 10.0),
        Image.network(_staticMapUri.toString()),
      ],
    );
  }
}

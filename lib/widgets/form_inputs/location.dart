import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
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
  final TextEditingController _addressInputController = TextEditingController();

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    super.initState();
  }

  void getStaticMap(String address) async {
    if (address.isEmpty) {
      return;
    }
    Uri uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json',
        {'address': address, 'key': 'AIzaSyBPqvb9-5ytCObTnJE3J5zw4wSP-yv1UQ4'});
    final http.Response response = await http.get(uri);
    print(response.body);

    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    final coords = decodedResponse['results'][0]['geometry']['location'];

    final StaticMapProvider staticMapProvider =
        StaticMapProvider('AIzaSyBPqvb9-5ytCObTnJE3J5zw4wSP-yv1UQ4');
    final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers([
      Marker('position', 'Position', coords['lat'], coords['lng']),
    ],
        center: Location(41.40338, 2.17403),
        width: 500,
        height: 300,
        maptype: StaticMapViewType.roadmap);
    setState(() {
      _addressInputController.text = formattedAddress;
      _staticMapUri = staticMapUri;
    });
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      getStaticMap(_addressInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            controller: _addressInputController,
            focusNode: _addressInputFocusNode,
            decoration: InputDecoration(labelText: 'Address'),
          ),
        ),
        SizedBox(height: 10.0),
        Image.network(_staticMapUri.toString()),
      ],
    );
  }
}

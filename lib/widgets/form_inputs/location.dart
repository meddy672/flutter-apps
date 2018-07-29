import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:map_view/map_view.dart';
import 'package:location/location.dart' as geoloc;

import '../helpers/ensure_visible.dart';
import '../../models/location_data.dart';
import '../../models/product.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return _LocationInput();
  }
}

class _LocationInput extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  Uri _staticMapUri;
  LocationData _locationData;
  final TextEditingController _addressInputController = TextEditingController();

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.product != null) {
      _getStaticMap(widget.product.location.address, geocode: false);
    }
    super.initState();
  }

  Future<String> _getAddress(double lat, double lng) async {

   Uri uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'latlng': '${lat.toString()},${lng.toString()}',
        'key': 'AIzaSyBPqvb9-5ytCObTnJE3J5zw4wSP-yv1UQ4'
      });
    final http.Response response = await http.get(uri);
    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    return formattedAddress;
  }

 void _getUserLocation() async{
   final location = geoloc.Location();
   final currentLocation = await location.getLocation;
   final address = await _getAddress(currentLocation['latitude'], currentLocation['longitude']);
   _getStaticMap(address, geocode: false, lat: currentLocation['latitude'], lng: currentLocation['lng']);
  }

  void _getStaticMap(String address, {bool geocode = true, double lat, double lng}) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geocode) {
      Uri uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'address': address,
        'key': 'AIzaSyBPqvb9-5ytCObTnJE3J5zw4wSP-yv1UQ4'
      });
      final http.Response response = await http.get(uri);

      final decodedResponse = json.decode(response.body);
      final formattedAddress =
          decodedResponse['results'][0]['formatted_address'];
      final coords = decodedResponse['results'][0]['geometry']['location'];
      _locationData = LocationData(
          latitude: coords['lat'],
          longitude: coords['lng'],
          address: formattedAddress);
    } else if(lat == null && lng == null) {
      _locationData = widget.product.location;
    }else{
      _locationData = LocationData(address: address, latitude: lat, longitude: lng);
    }

    final StaticMapProvider staticMapProvider =
        StaticMapProvider('AIzaSyBPqvb9-5ytCObTnJE3J5zw4wSP-yv1UQ4');
    final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers([
      Marker('position', 'Position', _locationData.latitude,
          _locationData.longitude),
    ],
        center: Location(41.40338, 2.17403),
        width: 500,
        height: 300,
        maptype: StaticMapViewType.roadmap);
    widget.setLocation(_locationData);
    setState(() {
      _addressInputController.text = _locationData.address;
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
      _getStaticMap(_addressInputController.text);
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
            validator: (String value) {
              if (_locationData == null || value.isEmpty) {
                return 'No valid location found.';
              }
            },
            decoration: InputDecoration(labelText: 'Address'),
          ),
        ),
        SizedBox(height:  10.0,),
        FlatButton(child: Text('Locate User'), onPressed: _getUserLocation,),
        SizedBox(height: 10.0),
        _staticMapUri == null
            ? Container()
            : Image.network(_staticMapUri.toString()),
      ],
    );
  }
}

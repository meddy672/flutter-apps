import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

import '../widgets/ui_elements/address_tag.dart';
import '../widgets/ui_elements/title_default.dart';
import '../models/product.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage(this.product);

  void _showMap() {
    print('!!!!!!!!!!!!!!!Map Function called!!!!!!!!!!!!!!');
    final List<Marker> marker = <Marker>[
      Marker('product', 'Product', product.location.latitude,
          product.location.longitude),
    ];
    final cameraPostion = CameraPosition(
        Location(product.location.latitude, product.location.longitude), 14.0);
    final mapView = MapView();
    mapView.show(
        MapOptions(
            initialCameraPosition: cameraPostion,
            mapViewType: MapViewType.normal,
            title: 'Product Location'),
        toolbarActions: [ToolbarAction('Close', 1)]);
    mapView.onToolbarAction.listen((int id) {
      if (id == 1) {
        mapView.dismiss();
      }
    });
    mapView.onMapReady.listen((_) {
      mapView.setMarkers(marker);
    });
  }

  Widget buildAddressContainer(String address, double price) {
    return Container(
      margin: EdgeInsets.only(left: 10.0, top: 20.0, right: 0.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: _showMap,
            child: AddressTag(
                address + ' | ' + price.toString()),
          ),
        ],
      ),
    );
  }

  Widget buildTitleContainer(String title, double price) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleDefault(
            title,
          ),
        ],
      ),
    );
  }

  Widget buildLabelContainer() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Description: ',
            style: TextStyle(fontFamily: 'Oswald', fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 10.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('Back button pressed!');
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FadeInImage(
              image: NetworkImage(product.image),
              height: 300.0,
              fit: BoxFit.cover,
              placeholder: AssetImage('assets/food.jpg'),
            ),
            buildTitleContainer(product.title, product.price),
            buildAddressContainer(product.location.address, product.price),
            buildLabelContainer(),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                product.description,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

import '../widgets/ui_elements/title_default.dart';
import '../models/product.dart';
import '../widgets/products/product_fab.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage(this.product);

  void _showMap() {
    print('!!!!!!!!!!!!!!!!!!MAP FUNCTION CALLED!!!!!!!!!!!!!!!!!!!!!');
    final List<Marker> markers = <Marker>[
      Marker('position', 'Position', product.location.latitude,
          product.location.longitude)
    ];
    final cameraPosition = CameraPosition(
        Location(product.location.latitude, product.location.longitude), 14.0);
    final mapView = MapView();
    mapView.show(
        MapOptions(
            initialCameraPosition: cameraPosition,
            mapViewType: MapViewType.normal,
            title: 'Product Location'),
        toolbarActions: [
          ToolbarAction('Close', 1),
        ]);
    mapView.onToolbarAction.listen((int id) {
      if (id == 1) {
        mapView.dismiss();
      }
    });
    mapView.onMapReady.listen((_) {
      mapView.setMarkers(markers);
    });
  }

  Widget _buildAddressPriceRow(String address, double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: _showMap,
          child: Text(
            address,
            style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            '|',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Text(
          '\$' + price.toString(),
          style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
        )
      ],
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
            _buildAddressPriceRow(product.location.address, product.price),
            buildLabelContainer(),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                product.description,
                textAlign: TextAlign.center,
              ),
            ),
            RaisedButton(onPressed: _showMap, child: Text('Show Product Location'),)
          ],
        ),
        floatingActionButton: ProductFAB(product),
      ),
    );
  }
}

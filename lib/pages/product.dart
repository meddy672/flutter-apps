import 'dart:async';


import 'package:flutter/material.dart';

import '../widgets/ui_elements/address_tag.dart';
import '../models/product.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage(this.product);


  Widget buildAddressContainer() {
    return Container(
      margin: EdgeInsets.only(left: 10.0, top: 20.0, right: 0.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AddressTag('Buckhead, Atlanta Georgia'),
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
          Text(
            title,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            ' | ',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            '\$${price.toString()}',
            style: TextStyle(
              color: Colors.grey,
            ),
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
            buildAddressContainer(),
            buildTitleContainer(product.title, product.price),
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

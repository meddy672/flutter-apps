import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/ui_elements/address_tag.dart';

class ProductPage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final double price;

  _showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('This action cannot be undone.'),
            actions: <Widget>[
              FlatButton(
                child: Text('DISCARD'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('CONTINUE'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
  }

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

  Widget buildTitleContainer() {
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

  Widget buildDeleteContainer(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: RaisedButton.icon(
          textColor: Colors.white,
          label: Text('DELETE'),
          icon: Icon(Icons.delete),
          shape: RoundedRectangleBorder(),
          color: Theme.of(context).accentColor,
          onPressed: () => _showWarningDialog(context),
        ),
      );
  }

  ProductPage(this.title, this.description, this.price, this.imageUrl);

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
          title: Text(title),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(imageUrl),
            buildAddressContainer(),
            buildTitleContainer(),
            buildLabelContainer(),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                description,
                textAlign: TextAlign.center,
              ),
            ),
            buildDeleteContainer(context),
          ],
        ),
      ),
    );
  }
}

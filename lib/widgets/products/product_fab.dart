import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/product.dart';
import '../../scoped-models/main.dart';

class ProductFAB extends StatefulWidget {

  final Product product;

  ProductFAB(this.product);

  @override
  State<StatefulWidget> createState() {
    return _ProductFABState();
  }
}

class _ProductFABState extends State<ProductFAB> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant(builder: (BuildContext context, Widget widget, MainModel model){
      return  Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).cardColor,
            heroTag: 'contact',
            mini: true,
            onPressed: () {},
            child: Icon(Icons.mail, color: Theme.of(context).primaryColor,),
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).cardColor,
            heroTag: 'favorite',
            mini: true,
            onPressed: () {
              model.toggleProductFavorite();
            },
            child: Icon( 
              model.selectedProduct.isFavorited 
              ? Icons.favorite 
              : Icons.favorite_border, 
              color: Colors.red,
              ),
          ),
        ),
        FloatingActionButton(
          onPressed: () {},
          heroTag: 'options',
          child: Icon(Icons.more_vert),
        ),
      ],
    );
    },);
  }
}

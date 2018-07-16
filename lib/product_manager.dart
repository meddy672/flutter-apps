import 'package:flutter/material.dart';

import './products.dart';

class ProductManager extends StatefulWidget{

  final String startingProduct;

  // Starting point is not defined initialize starting point
  ProductManager({this.startingProduct = 'Sweets Tester'} ){

    print('[ProductManager State] Constructor');
  }

  @override
    State<StatefulWidget> createState() {
      // TODO: implement createState

      print('[ProductManager State] createState()');
      return _ProductManagerState();
    }

}

class _ProductManagerState extends State<ProductManager>{
List <String> _products = [];

  @override
  void initState(){

    print('[Product Manager State] initState()');
    _products.add(widget.startingProduct);
    super.initState();
  }

  void didUpdateWidget(ProductManager oldWidget){

    print('[Product Manager State] didUpdateWidget()');
    super.didUpdateWidget(oldWidget);
  }

  Widget build(BuildContext context){

    print('[ProductManager] build()');
    return Column(children: [Container(
        margin: EdgeInsets.all(10.0),
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            setState(() {
                _products.add('Advance Food Tester');                  
            });
          },
          child: Text('Add Product'),
    )),
    Products(_products)   
    ],);
  }
}
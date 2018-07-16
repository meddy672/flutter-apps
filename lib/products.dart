import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  final List<String> products;

  // if no list is passed set products to empty list
  Products( [this.products = const [] ] ){
print('[Products] Constructor');
  }

  Widget build(BuildContext context) {
    print('[Products] build()');
    return Column(
      children: products
          .map((element) => Card(
              child: Column(
                children: <Widget>[
                  Image.asset('assets/food.jpg'),
                  Text(element)
                ],
              )))
          .toList());
  }
}
